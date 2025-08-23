//
//  BarcodeOverlayView.swift
//  apus
//
//  Created by wa-ik on 2025/08/17.
//

import SwiftUI
import Vision

/// Enhanced barcode overlay with QR code specific features and smart content detection
struct BarcodeOverlayView: View {
    let barcodes: [VNBarcodeObservation]
    let imageSize: CGSize
    let displaySize: CGSize
    @State private var selectedBarcode: VNBarcodeObservation?
    @State private var showingActionSheet = false

    // Inject barcode detection manager for content parsing
    private let barcodeManager = BarcodeDetectionManager()

    var body: some View {
        ZStack {
            ForEach(barcodes, id: \.uuid) { barcode in
                let transformedRect = transformBoundingBox(barcode.boundingBox, from: imageSize, to: displaySize)
                let isQRCode = barcode.symbology == .qr
                let contentType = parseContentType(barcode)

                // Draw bounding box with different colors for different types
                Rectangle()
                    .stroke(getBorderColor(for: barcode), lineWidth: isQRCode ? 3 : 2)
                    .frame(width: transformedRect.width, height: transformedRect.height)
                    .position(x: transformedRect.midX, y: transformedRect.midY)
                    .onTapGesture {
                        selectedBarcode = barcode
                        showingActionSheet = true
                    }

                // Enhanced label with content type icon and preview
                HStack(spacing: 4) {
                    Image(systemName: getIcon(for: contentType))
                        .font(.caption2)

                    Text(getDisplayText(for: barcode, contentType: contentType))
                        .font(.caption2)
                        .lineLimit(1)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(getBorderColor(for: barcode).opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .position(x: transformedRect.midX, y: transformedRect.minY - 15)

                // QR Code corner indicators for better visibility
                if isQRCode {
                    ForEach(0..<4, id: \.self) { corner in
                        cornerIndicator(for: corner, in: transformedRect)
                    }
                }
            }
        }
        .actionSheet(isPresented: $showingActionSheet) {
            createActionSheet(for: selectedBarcode)
        }
    }

    // MARK: - Helper Methods

    private func parseContentType(_ barcode: VNBarcodeObservation) -> QRCodeContentType {
        guard let payload = barcode.payloadStringValue else {
            return .unknown("")
        }
        return barcodeManager.parseQRCodeContent(payload)
    }

    private func getBorderColor(for barcode: VNBarcodeObservation) -> Color {
        if barcode.symbology == .qr {
            let contentType = parseContentType(barcode)
            switch contentType {
            case .url: return .blue
            case .email: return .green
            case .phone: return .orange
            case .wifi: return .purple
            case .contact: return .pink
            case .sms: return .cyan
            case .text: return .yellow
            case .unknown: return .red
            }
        } else {
            return .red // Traditional barcodes
        }
    }

    private func getIcon(for contentType: QRCodeContentType) -> String {
        return contentType.icon
    }

    private func getDisplayText(for barcode: VNBarcodeObservation, contentType: QRCodeContentType) -> String {
        let symbologyText = barcode.symbology == .qr ? "QR" : barcode.symbology.rawValue.uppercased()

        switch contentType {
        case .url(let url):
            return "\(symbologyText): \(url.host ?? url.absoluteString)"
        case .email(let email):
            return "\(symbologyText): \(email)"
        case .phone(let phone):
            return "\(symbologyText): \(phone)"
        case .wifi(let ssid, _, _):
            return "\(symbologyText): WiFi \(ssid)"
        case .contact:
            return "\(symbologyText): Contact"
        case .sms(let number, _):
            return "\(symbologyText): SMS \(number)"
        case .text(let text):
            let preview = text.count > 20 ? String(text.prefix(20)) + "..." : text
            return "\(symbologyText): \(preview)"
        case .unknown(let content):
            let preview = content.count > 15 ? String(content.prefix(15)) + "..." : content
            return "\(symbologyText): \(preview)"
        }
    }

    private func cornerIndicator(for corner: Int, in rect: CGRect) -> some View {
        let cornerSize: CGFloat = 12
        let offset: CGFloat = 4

        let position: CGPoint
        let rotation: Double

        switch corner {
        case 0: // Top-left
            position = CGPoint(x: rect.minX - offset, y: rect.minY - offset)
            rotation = 0
        case 1: // Top-right
            position = CGPoint(x: rect.maxX + offset, y: rect.minY - offset)
            rotation = 90
        case 2: // Bottom-right
            position = CGPoint(x: rect.maxX + offset, y: rect.maxY + offset)
            rotation = 180
        case 3: // Bottom-left
            position = CGPoint(x: rect.minX - offset, y: rect.maxY + offset)
            rotation = 270
        default:
            position = .zero
            rotation = 0
        }

        return Image(systemName: "qrcode.viewfinder")
            .font(.system(size: cornerSize))
            .foregroundColor(.white)
            .background(Color.black.opacity(0.7))
            .clipShape(Circle())
            .rotationEffect(.degrees(rotation))
            .position(position)
    }

    private func createActionSheet(for barcode: VNBarcodeObservation?) -> ActionSheet {
        guard let barcode = barcode,
              let payload = barcode.payloadStringValue else {
            return ActionSheet(title: Text("Barcode"), buttons: [.cancel()])
        }

        let contentType = parseContentType(barcode)
        var buttons: [ActionSheet.Button] = []

        // Add primary action based on content type
        switch contentType {
        case .url(let url):
            buttons.append(.default(Text("Open URL")) {
                UIApplication.shared.open(url)
            })
        case .email(let email):
            buttons.append(.default(Text("Send Email")) {
                if let url = URL(string: "mailto:\(email)") {
                    UIApplication.shared.open(url)
                }
            })
        case .phone(let phone):
            buttons.append(.default(Text("Call Number")) {
                if let url = URL(string: "tel:\(phone)") {
                    UIApplication.shared.open(url)
                }
            })
        case .sms(let number, _):
            buttons.append(.default(Text("Send SMS")) {
                if let url = URL(string: "sms:\(number)") {
                    UIApplication.shared.open(url)
                }
            })
        case .wifi(let ssid, let password, _):
            buttons.append(.default(Text("Copy WiFi Info")) {
                let wifiInfo = password != nil ? "Network: \(ssid)\nPassword: \(password!)" : "Network: \(ssid)"
                UIPasteboard.general.string = wifiInfo
            })
        default:
            break
        }

        // Always add copy option
        buttons.append(.default(Text("Copy Content")) {
            UIPasteboard.general.string = payload
        })

        buttons.append(.cancel())

        return ActionSheet(
            title: Text(barcode.symbology == .qr ? "QR Code" : "Barcode"),
            message: Text(contentType.actionTitle),
            buttons: buttons
        )
    }

    /// Transforms a bounding box from image coordinates to display coordinates.
    private func transformBoundingBox(_ box: CGRect, from imageSize: CGSize, to displaySize: CGSize) -> CGRect {
        // Vision framework coordinates are normalized and have origin at bottom-left.
        // We need to convert to top-left origin for SwiftUI.
        return CGRect(
            x: box.origin.x * displaySize.width,
            y: (1 - box.origin.y - box.height) * displaySize.height,
            width: box.width * displaySize.width,
            height: box.height * displaySize.height
        )
    }
}

struct BarcodeDetectionOverlay: View {
    let barcodes: [VNBarcodeObservation]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(barcodes, id: \.self) { barcode in
                    let boundingBox = barcode.boundingBox
                    let rect = CGRect(
                        x: boundingBox.origin.x * geometry.size.width,
                        y: (1 - boundingBox.origin.y - boundingBox.height) * geometry.size.height,
                        width: boundingBox.width * geometry.size.width,
                        height: boundingBox.height * geometry.size.height
                    )

                    Rectangle()
                        .stroke(Color.red, lineWidth: 2)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)

                    Text(barcode.payloadStringValue ?? "")
                        .foregroundColor(.white)
                        .background(Color.red)
                        .position(x: rect.midX, y: rect.midY)
                }
            }
        }
    }
}
