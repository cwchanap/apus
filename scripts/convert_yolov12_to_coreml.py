#!/usr/bin/env python3
"""
Convert YOLOv12s PyTorch weights to Core ML (.mlpackage or .mlmodel).

Two conversion paths are supported:
1) Ultralytics exporter (if `ultralytics` can load the model):
   - Uses YOLO().export(format="coreml")
2) Generic PyTorch -> ONNX -> Core ML conversion:
   - Loads a TorchScript or nn.Module checkpoint from `.pt`
   - Exports to ONNX with dynamic H/W
   - Optionally simplifies ONNX
   - Converts ONNX to Core ML via coremltools

Note: Depending on how the `.pt` file was created, the generic path may
require the model to be torchscriptable or contain a full module in
`checkpoint['model']`. If neither applies, use the project/repo that
defines the YOLOv12 model class to load the weights before export.

Usage (with uv):
  uv run scripts/convert_yolov12_to_coreml.py \
    --weights https://github.com/sunsmarterjie/yolov12/releases/download/v1.0/yolov12s.pt \
    --imgsz 640 \
    --output models/yolov12s

This will try Ultralytics first (if installed), then fall back to ONNX->CoreML.
"""

from __future__ import annotations

import argparse
import os
import sys
import tempfile
from pathlib import Path

import numpy as np
import requests
from tqdm import tqdm


def download_file(url: str, dst: Path, chunk_size: int = 1 << 20) -> Path:
    dst.parent.mkdir(parents=True, exist_ok=True)
    with requests.get(url, stream=True, timeout=30) as r:
        r.raise_for_status()
        total = int(r.headers.get("content-length", 0))
        with tqdm(total=total, unit="B", unit_scale=True, desc=f"Downloading {dst.name}") as pbar:
            with open(dst, "wb") as f:
                for chunk in r.iter_content(chunk_size=chunk_size):
                    if chunk:
                        f.write(chunk)
                        pbar.update(len(chunk))
    return dst


def try_ultralytics_export_coreml(weights: Path, imgsz: int, out_root: Path) -> Path | None:
    try:
        from ultralytics import YOLO  # type: ignore
    except Exception:
        return None

    try:
        print("[ultralytics] Attempting Core ML export via Ultralytics...")
        model = YOLO(str(weights))
        # Ultralytics expects square size or tuple (h, w)
        export_result = model.export(format="coreml", imgsz=imgsz, opset=13, half=False)

        # Collect candidates: next to weights and in common Ultralytics output dirs
        candidates = []
        candidates += list(weights.parent.glob("*coreml*"))
        candidates += list(weights.parent.glob("*.mlmodel"))
        candidates += list(weights.parent.glob("*.mlpackage"))
        # Search cwd recursively for recent mlmodels (Ultralytics often saves to runs/)
        try:
            for p in Path.cwd().rglob("*.mlmodel"):
                candidates.append(p)
            for p in Path.cwd().rglob("*.mlpackage"):
                candidates.append(p)
        except Exception:
            pass

        if candidates:
            produced = sorted(candidates, key=lambda p: p.stat().st_mtime, reverse=True)[0]
            if produced.suffix in (".mlpackage", ".mlmodel"):
                target = out_root.with_suffix(produced.suffix)
            else:
                out_root.mkdir(parents=True, exist_ok=True)
                target = out_root / produced.name
            if produced.resolve() != target.resolve():
                try:
                    produced.replace(target)
                except Exception:
                    # If cross-filesystem move fails, copy
                    import shutil
                    shutil.copy2(str(produced), str(target))
            print(f"[ultralytics] Exported: {target}")
            return target
        print("[ultralytics] Export reported success but no artifact found.")
        # If export_result looks like a path, try it
        try:
            from pathlib import Path as _P
            p = _P(str(export_result))
            if p.exists():
                target = out_root.with_suffix(p.suffix)
                if p.resolve() != target.resolve():
                    import shutil
                    shutil.copy2(str(p), str(target))
                print(f"[ultralytics] Exported via return value: {target}")
                return target
        except Exception:
            pass
        return None
    except Exception as e:
        print(f"[ultralytics] Export failed: {e}")
        return None


def export_onnx(weights: Path, imgsz: int, onnx_path: Path) -> Path:
    import torch
    dummy = torch.zeros(1, 3, imgsz, imgsz)

    model = None
    err_msgs = []

    # Try TorchScript first
    try:
        model = torch.jit.load(str(weights), map_location="cpu")
        model.eval()
        print("[onnx] Loaded TorchScript module")
    except Exception as e:
        err_msgs.append(f"torch.jit.load failed: {e}")

    # Try checkpoint with module
    if model is None:
        try:
            ckpt = torch.load(str(weights), map_location="cpu")
            if isinstance(ckpt, dict) and "model" in ckpt:
                model = ckpt["model"]
                if hasattr(model, "float"):
                    model.float()
                model.eval()
                print("[onnx] Loaded nn.Module from checkpoint['model']")
        except Exception as e:
            err_msgs.append(f"torch.load failed: {e}")

    if model is None:
        msg = (
            "Unable to load model from weights. "
            "Ensure the .pt is TorchScript or contains checkpoint['model'].\n" + "\n".join(err_msgs)
        )
        raise RuntimeError(msg)

    onnx_path.parent.mkdir(parents=True, exist_ok=True)
    dynamic_axes = {"images": {2: "height", 3: "width"}}
    input_names = ["images"]
    output_names = [f"output{i}" for i in range(3)]  # heuristic for YOLO heads

    print(f"[onnx] Exporting to {onnx_path} (opset 13)")
    torch.onnx.export(
        model,
        dummy,
        str(onnx_path),
        input_names=input_names,
        output_names=output_names,
        dynamic_axes=dynamic_axes,
        opset_version=13,
        do_constant_folding=True,
    )
    print("[onnx] Export complete")
    return onnx_path


def maybe_simplify_onnx(onnx_path: Path) -> Path:
    try:
        import onnx
        from onnxsim import simplify  # type: ignore
    except Exception:
        print("[onnxsim] onnxsim not available, skipping simplification")
        return onnx_path

    print("[onnxsim] Simplifying ONNX...")
    model = onnx.load(str(onnx_path))
    model_simplified, check = simplify(model)
    if not check:
        print("[onnxsim] Simplification check failed; using original ONNX")
        return onnx_path
    simp_path = onnx_path.with_suffix(".simplified.onnx")
    onnx.save(model_simplified, str(simp_path))
    print(f"[onnxsim] Wrote {simp_path}")
    return simp_path


def try_ultralytics_export_onnx(weights: Path, imgsz: int, out_root: Path) -> Path | None:
    try:
        from ultralytics import YOLO  # type: ignore
    except Exception:
        return None

    try:
        print("[ultralytics] Attempting ONNX export via Ultralytics...")
        model = YOLO(str(weights))
        export_result = model.export(format="onnx", imgsz=imgsz, opset=13, half=False, simplify=False)

        candidates = []
        candidates += list(weights.parent.glob("*.onnx"))
        # Search cwd for onnx in common places (e.g. runs/)
        try:
            for p in Path.cwd().rglob("*.onnx"):
                candidates.append(p)
        except Exception:
            pass

        if candidates:
            produced = sorted(candidates, key=lambda p: p.stat().st_mtime, reverse=True)[0]
            target = out_root.with_suffix(".onnx")
            if produced.resolve() != target.resolve():
                try:
                    produced.replace(target)
                except Exception:
                    import shutil
                    shutil.copy2(str(produced), str(target))
            print(f"[ultralytics] ONNX exported: {target}")
            return target

        # Try export_result if it looks like a path
        try:
            p = Path(str(export_result))
            if p.exists():
                target = out_root.with_suffix(".onnx")
                if p.resolve() != target.resolve():
                    import shutil
                    shutil.copy2(str(p), str(target))
                print(f"[ultralytics] ONNX exported via return value: {target}")
                return target
        except Exception:
            pass

        print("[ultralytics] ONNX export reported success but no artifact found.")
        return None
    except Exception as e:
        print(f"[ultralytics] ONNX export failed: {e}")
        return None


def onnx_to_coreml(onnx_path: Path, out_dir: Path, fp16: bool) -> Path:
    import coremltools as ct

    out_dir.mkdir(parents=True, exist_ok=True)
    print("[coreml] Converting ONNX to Core ML...")
    mlmodel = ct.convert(
        onnx_path,
        source="onnx",
        convert_to="mlprogram",
        minimum_deployment_target=ct.target.iOS17,
        compute_units=ct.ComputeUnit.ALL,
        compute_precision=ct.precision.FLOAT16 if fp16 else ct.precision.FLOAT32,
    )

    # Choose container format; mlpackage preferred for modern Core ML
    out_path = out_dir / f"{onnx_path.stem}.mlpackage"
    try:
        mlmodel.save(str(out_path))
    except Exception:
        out_path = out_dir / f"{onnx_path.stem}.mlmodel"
        mlmodel.save(str(out_path))

    print(f"[coreml] Saved {out_path}")
    return out_path


def parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(description="Convert YOLOv12s .pt to Core ML")
    p.add_argument("--weights", type=str, required=True,
                   help="Path or URL to yolov12s.pt")
    p.add_argument("--imgsz", type=int, default=640,
                   help="Image size (square). Default: 640")
    p.add_argument("--output", type=str, default="models/yolov12s",
                   help="Output directory (without extension). Default: models/yolov12s")
    p.add_argument("--onnx-only", action="store_true",
                   help="Only export ONNX (skip Core ML conversion)")
    p.add_argument("--no-ultralytics", action="store_true",
                   help="Skip attempting Ultralytics export path")
    p.add_argument("--onnx-first", action="store_true",
                   help="Try Ultralytics ONNX export first, then Core ML conversion")
    p.add_argument("--fp16", action="store_true",
                   help="Use FP16 precision for Core ML (smaller, faster)")
    return p.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)

    out_root = Path(args.output)
    out_root.parent.mkdir(parents=True, exist_ok=True)

    # Resolve weights (download if URL)
    weights_path = Path(args.weights)
    if args.weights.startswith("http://") or args.weights.startswith("https://"):
        weights_dir = Path("models")
        weights_dir.mkdir(parents=True, exist_ok=True)
        weights_path = weights_dir / Path(args.weights).name
        if not weights_path.exists():
            print(f"Downloading weights from {args.weights}...")
            download_file(args.weights, weights_path)
        else:
            print(f"Using cached weights at {weights_path}")

    # Decide flow based on onnx-first preference
    if not args.no_ultralytics and args.onnx_first:
        # 1) Try Ultralytics ONNX export
        onnx_from_ultra = try_ultralytics_export_onnx(weights_path, args.imgsz, out_root)
        if onnx_from_ultra is not None:
            onnx_path = onnx_from_ultra
        else:
            # 2) Fallback to generic PyTorch->ONNX
            onnx_path = out_root.with_suffix(".onnx")
            try:
                onnx_path = export_onnx(weights_path, args.imgsz, onnx_path)
            except Exception as e:
                print(f"[onnx] Export failed: {e}")
                return 2

        # Optional simplify (best-effort)
        onnx_path = maybe_simplify_onnx(onnx_path)

        if args.onnx_only:
            print(f"[done] ONNX written to: {onnx_path}")
            return 0

        # Convert to Core ML
        try:
            coreml_path = onnx_to_coreml(onnx_path, out_root.parent, args.fp16)
            print(f"[done] Core ML model at: {coreml_path}")
            return 0
        except Exception as e:
            print(f"[coreml] Conversion failed: {e}")
            return 3

    # Default: try Ultralytics direct Core ML, then generic path
    if not args.no_ultralytics:
        coreml_path = try_ultralytics_export_coreml(weights_path, args.imgsz, out_root)
        if coreml_path:
            return 0

    # Fallback: PyTorch -> ONNX -> Core ML
    onnx_path = out_root.with_suffix(".onnx")
    try:
        onnx_path = export_onnx(weights_path, args.imgsz, onnx_path)
    except Exception as e:
        print(f"[onnx] Export failed: {e}")
        return 2

    onnx_path = maybe_simplify_onnx(onnx_path)

    if args.onnx_only:
        print(f"[done] ONNX written to: {onnx_path}")
        return 0

    try:
        coreml_path = onnx_to_coreml(onnx_path, out_root.parent, args.fp16)
        print(f"[done] Core ML model at: {coreml_path}")
        return 0
    except Exception as e:
        print(f"[coreml] Conversion failed: {e}")
        return 3


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
