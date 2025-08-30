YOLOv12s → Core ML Conversion

Overview
- Converts YOLOv12s PyTorch weights (`.pt`) to Core ML (`.mlpackage` or `.mlmodel`).
- Manages Python deps via `uv` using the repository `pyproject.toml`.

Prereqs
- Python 3.9+; `uv` installed (https://github.com/astral-sh/uv)
- Xcode with Core ML tools available on macOS.

Setup
1) Install deps into a managed venv:
   uv sync

Convert
- Download and convert the published YOLOv12s weights:
  uv run scripts/convert_yolov12_to_coreml.py \
    --weights https://github.com/sunsmarterjie/yolov12/releases/download/v1.0/yolov12s.pt \
    --imgsz 640 \
    --output models/yolov12s

Outputs
- ONNX: `models/yolov12s.onnx`
- Core ML: `models/yolov12s.mlpackage` (or `.mlmodel` if package save fails)

Flags
- `--onnx-only`: stop after ONNX export
- `--no-ultralytics`: skip Ultralytics exporter path
- `--fp16`: export Core ML with float16 precision for smaller size

Integrate into iOS app
1) Drag the resulting `yolov12s.mlpackage` (preferred) or `.mlmodel` into the Xcode project target.
2) Ensure `coco_labels.txt` is present in the bundle (one label per line).
3) Run the app on device. The DI factory prefers Core ML YOLO if the model is found; otherwise it falls back to Vision.
4) Adjust score or IoU thresholds in `YOLOv12CoreMLObjectDetectionManager` if needed.

Notes
- This export uses a generic ONNX → Core ML pipeline; some models may require decoding inside the model graph. The Swift postprocessor expects rows like `[x, y, w, h, obj, cls0..clsN]` in model input pixel coordinates. If your export differs, tweak the decode logic accordingly.
