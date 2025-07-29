//
//  CameraView.swift
//  apus
//
//  Created by Chan Wai Chan on 29/6/2025.
//

import SwiftUI
import AVFoundation
import Photos
import CoreVideo

struct CameraView: View {
    @StateObject private var camera = CameraManager()
    @StateObject private var objectDetection = ObjectDetectionProvider()
    @State private var showingImagePicker = false
    @State private var capturedImage: UIImage?
    
    var body: some View {
        let isShowingPreview = Binding<Bool>(
            get: { self.capturedImage != nil },
            set: { if !$0 { self.capturedImage = nil } }
        )

        return ZStack {
            // Camera preview
            CameraPreview(camera: camera)
                .ignoresSafeArea()
            
            // Object detection overlay
            ObjectDetectionOverlay(detections: objectDetection.detections)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Camera controls
                HStack(spacing: 50) {
                    // Gallery button
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    // Capture button
                    Button(action: {
                        camera.capturePhoto { image in
                            if let image = image {
                                capturedImage = image
                            }
                        }
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 70, height: 70)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 60, height: 60)
                            )
                    }
                    
                    // Switch camera button
                    Button(action: {
                        camera.switchCamera()
                    }) {
                        Image(systemName: "camera.rotate")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom, 50)
            }
            
            // Hidden NavigationLink for the preview
            .navigationDestination(isPresented: isShowingPreview) {
                PreviewView(capturedImage: $capturedImage)
            }
        }
        .onAppear {
            camera.requestPermission()
            camera.setObjectDetectionManager(objectDetection)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Restart camera when app becomes active (fixes initial load issue)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if camera.isAuthorized && !camera.session.isRunning {
                    camera.requestPermission()
                }
            }
        }
        .onDisappear {
            camera.stopSession()
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $capturedImage)
        }
    }
}

// Camera Manager
class CameraManager: NSObject, ObservableObject {
    @Published var session = AVCaptureSession()
    @Published var output = AVCapturePhotoOutput()
    @Published var preview = AVCaptureVideoPreviewLayer()
    @Published var isAuthorized = false
    
    private var currentCamera: AVCaptureDevice?
    private var photoCompletionHandler: ((UIImage?) -> Void)?
    private var videoDataOutput = AVCaptureVideoDataOutput()
    private var objectDetectionManager: (any ObjectDetectionProtocol)?
    
    func requestPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            isAuthorized = true
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isAuthorized = granted
                    if granted {
                        self.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    private func setupCamera() {
        session.beginConfiguration()
        
        // Remove existing inputs
        session.inputs.forEach { session.removeInput($0) }
        
        // Add camera input
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration()
            return
        }
        
        guard let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            return
        }
        
        currentCamera = camera
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        // Add photo output
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        // Add video data output for object detection
        videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInitiated))
        
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        // Configure session
        session.sessionPreset = .photo
        
        session.commitConfiguration()
        
        // Start the session
        if !session.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        }
        
        // Setup preview layer
        DispatchQueue.main.async {
            self.preview.session = self.session
            self.preview.videoGravity = .resizeAspectFill
            
            // Force refresh after a short delay (fixes initial load issue)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.preview.connection?.isEnabled = false
                self.preview.connection?.isEnabled = true
            }
        }
        
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard session.isRunning else {
            completion(nil)
            return
        }
        
        photoCompletionHandler = completion
        
        let settings = AVCapturePhotoSettings()
        
        // Check if flash is available before setting it
        if let device = currentCamera, device.hasFlash {
            settings.flashMode = .auto
        }
        
        // Ensure we can capture with these settings
        guard output.connection(with: .video) != nil else {
            completion(nil)
            return
        }
        
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func switchCamera() {
        session.beginConfiguration()
        
        // Remove current input
        session.inputs.forEach { session.removeInput($0) }
        
        // Switch camera position
        let newPosition: AVCaptureDevice.Position = currentCamera?.position == .back ? .front : .back
        
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: newPosition),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            return
        }
        
        currentCamera = camera
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        session.commitConfiguration()
    }
    
    func setObjectDetectionManager(_ manager: any ObjectDetectionProtocol) {
        objectDetectionManager = manager
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
}

// Camera Preview
struct CameraPreview: UIViewRepresentable {
    @ObservedObject var camera: CameraManager
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = .black
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Remove existing preview layer
        uiView.layer.sublayers?.removeAll { $0 is AVCaptureVideoPreviewLayer }
        
        // Only add preview layer if view has proper size
        guard uiView.bounds.width > 0 && uiView.bounds.height > 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.updateUIView(uiView, context: context)
            }
            return
        }
        
        // Add current preview layer with proper frame
        camera.preview.frame = uiView.bounds
        uiView.layer.addSublayer(camera.preview)
    }
}

// Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiView: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// AVCapturePhotoOutput Delegate
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            photoCompletionHandler?(nil)
            return
        }
        
        photoCompletionHandler?(image)
        photoCompletionHandler = nil
    }
}

// AVCaptureVideoDataOutput Delegate
extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        objectDetectionManager?.processFrame(pixelBuffer)
    }
}

// Object Detection Overlay
struct ObjectDetectionOverlay: View {
    let detections: [Detection]
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(detections.indices, id: \.self) { index in
                let detection = detections[index]
                let boundingBox = scaleBoundingBox(detection.boundingBox, to: geometry.size)
                
                ZStack {
                    Rectangle()
                        .stroke(Color.red, lineWidth: 2)
                        .frame(width: boundingBox.width, height: boundingBox.height)
                    
                    VStack {
                        Text("\(detection.className)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(4)
                        
                        Text(String(format: "%.2f", detection.confidence))
                            .font(.caption2)
                            .foregroundColor(.white)
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(4)
                        
                        Spacer()
                    }
                }
                .position(x: boundingBox.midX, y: boundingBox.midY)
            }
        }
    }
    
    private func scaleBoundingBox(_ boundingBox: CGRect, to size: CGSize) -> CGRect {
        let scaleX = size.width
        let scaleY = size.height
        
        return CGRect(
            x: boundingBox.minX * scaleX,
            y: boundingBox.minY * scaleY,
            width: boundingBox.width * scaleX,
            height: boundingBox.height * scaleY
        )
    }
}

#Preview {
    CameraView()
}
