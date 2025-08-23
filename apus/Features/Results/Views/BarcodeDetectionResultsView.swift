//
//  BarcodeDetectionResultsView.swift
//  apus
//
//  Created by wa-ik on 2025/08/17
//
import SwiftUI
import Vision

struct BarcodeDetectionResultsView: View {
    @EnvironmentObject var resultsManager: DetectionResultsManager
    @State private var selectedResult: StoredBarcodeDetectionResult?
    @State private var showingDetailView = false
    @Environment(\.dismiss) private var dismiss

    private let barcodeManager = BarcodeDetectionManager()

    var body: some View {
        Group {
            if resultsManager.barcodeResults.isEmpty {
                EmptyResultsView(
                    category: .barcode,
                    message: "No barcode results yet",
                    description: "Scan barcodes and QR codes to see results here"
                )
            } else {
                List {
                    ForEach(resultsManager.barcodeResults) { result in
                        BarcodeResultRow(result: result, barcodeManager: barcodeManager) {
                            selectedResult = result
                            showingDetailView = true
                        }
                    }
                    .onDelete(perform: deleteResults)
                }
                .refreshable {
                    // Refresh functionality if needed
                }
            }
        }
        .navigationTitle("Barcode Results")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                if !resultsManager.barcodeResults.isEmpty {
                    Button("Clear All") {
                        resultsManager.clearBarcodeDetectionResults()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .sheet(isPresented: $showingDetailView) {
            if let result = selectedResult {
                BarcodeResultDetailView(result: result, barcodeManager: barcodeManager)
            }
        }
    }

    private func deleteResults(at offsets: IndexSet) {
        resultsManager.barcodeResults.remove(atOffsets: offsets)
    }
}

// MARK: - Barcode Result Row
struct BarcodeResultRow: View {
    let result: StoredBarcodeDetectionResult
    let barcodeManager: BarcodeDetectionManager
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Thumbnail
                if let image = result.thumbnailImage ?? result.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                VStack(alignment: .leading, spacing: 4) {
                    // Summary
                    HStack {
                        Text("\(result.detectedBarcodes.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(result.detectedBarcodes.count == 1 ? "barcode" : "barcodes")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // QR Code preview if available
                    if let firstQR = result.detectedBarcodes.first(where: { $0.symbology == "QR" }) {
                        let contentType = barcodeManager.parseQRCodeContent(firstQR.payload)
                        HStack(spacing: 4) {
                            Image(systemName: contentType.icon)
                                .foregroundColor(getContentColor(contentType))
                                .font(.caption)
                            Text(getContentPreview(contentType))
                                .font(.caption)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                        }
                    }

                    // Timestamp
                    Text(result.timestamp, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Type indicators
                VStack(alignment: .trailing, spacing: 2) {
                    let qrCount = result.detectedBarcodes.filter { $0.symbology == "QR" }.count
                    let barcodeCount = result.detectedBarcodes.count - qrCount

                    if qrCount > 0 {
                        Label("\(qrCount)", systemImage: "qrcode")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }

                    if barcodeCount > 0 {
                        Label("\(barcodeCount)", systemImage: "barcode")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func getContentColor(_ contentType: QRCodeContentType) -> Color {
        switch contentType {
        case .url: return .blue
        case .email: return .green
        case .phone: return .orange
        case .wifi: return .purple
        case .contact: return .pink
        case .sms: return .cyan
        case .text: return .primary
        case .unknown: return .secondary
        }
    }

    private func getContentPreview(_ contentType: QRCodeContentType) -> String {
        switch contentType {
        case .url(let url): return url.host ?? url.absoluteString
        case .email(let email): return email
        case .phone(let phone): return phone
        case .wifi(let ssid, _, _): return "WiFi: \(ssid)"
        case .contact: return "Contact Card"
        case .sms(let number, _): return "SMS: \(number)"
        case .text(let text): return text.count > 30 ? String(text.prefix(30)) + "..." : text
        case .unknown(let content): return content.count > 30 ? String(content.prefix(30)) + "..." : content
        }
    }
}

// MARK: - Barcode Result Detail View
struct BarcodeResultDetailView: View {
    let result: StoredBarcodeDetectionResult
    let barcodeManager: BarcodeDetectionManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Image
                    if let image = result.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    // Barcodes list
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(result.detectedBarcodes.enumerated()), id: \.offset) { index, barcode in
                            BarcodeDetailCard(
                                barcode: barcode,
                                index: index + 1,
                                barcodeManager: barcodeManager
                            )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Barcode Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Barcode Detail Card
struct BarcodeDetailCard: View {
    let barcode: StoredDetectedBarcode
    let index: Int
    let barcodeManager: BarcodeDetectionManager
    @State private var showingActionSheet = false

    var body: some View {
        let contentType = barcodeManager.parseQRCodeContent(barcode.payload)

        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("Barcode \(index)")
                    .font(.headline)
                Spacer()
                Text(barcode.symbology)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(barcode.symbology == "QR" ? Color.blue : Color.orange)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }

            // Content preview with icon
            HStack(spacing: 8) {
                Image(systemName: contentType.icon)
                    .foregroundColor(getContentColor(contentType))
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(getContentTitle(contentType))
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(barcode.payload)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }

                Spacer()
            }

            // Action button
            Button(action: { showingActionSheet = true }) {
                HStack {
                    Image(systemName: "hand.tap")
                    Text(contentType.actionTitle)
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(getContentColor(contentType))
                .clipShape(Capsule())
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .actionSheet(isPresented: $showingActionSheet) {
            createActionSheet(for: barcode, contentType: contentType)
        }
    }

    private func getContentColor(_ contentType: QRCodeContentType) -> Color {
        switch contentType {
        case .url: return .blue
        case .email: return .green
        case .phone: return .orange
        case .wifi: return .purple
        case .contact: return .pink
        case .sms: return .cyan
        case .text: return .primary
        case .unknown: return .secondary
        }
    }

    private func getContentTitle(_ contentType: QRCodeContentType) -> String {
        switch contentType {
        case .url: return "Website URL"
        case .email: return "Email Address"
        case .phone: return "Phone Number"
        case .wifi: return "WiFi Network"
        case .contact: return "Contact Information"
        case .sms: return "SMS Message"
        case .text: return "Text Content"
        case .unknown: return "Unknown Content"
        }
    }

    private func createActionSheet(for barcode: StoredDetectedBarcode, contentType: QRCodeContentType) -> ActionSheet {
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
            UIPasteboard.general.string = barcode.payload
        })

        buttons.append(.cancel())

        return ActionSheet(
            title: Text(barcode.symbology),
            message: Text(contentType.actionTitle),
            buttons: buttons
        )
    }
}
