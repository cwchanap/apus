
//
//  BarcodeDetectionManager.swift
//  apus
//
//  Created by wa-ik on 2025/08/17
//
import AVFoundation
import Vision
import UIKit

// MARK: - QR Code Content Types
enum QRCodeContentType {
    case url(URL)
    case text(String)
    case email(String)
    case phone(String)
    case wifi(ssid: String, password: String?, security: String?)
    case contact(vCard: String)
    case sms(number: String, message: String?)
    case unknown(String)
    
    var actionTitle: String {
        switch self {
        case .url: return "Open URL"
        case .text: return "Copy Text"
        case .email: return "Send Email"
        case .phone: return "Call Number"
        case .wifi: return "Connect to WiFi"
        case .contact: return "Add Contact"
        case .sms: return "Send SMS"
        case .unknown: return "Copy Content"
        }
    }
    
    var icon: String {
        switch self {
        case .url: return "link"
        case .text: return "doc.text"
        case .email: return "envelope"
        case .phone: return "phone"
        case .wifi: return "wifi"
        case .contact: return "person.crop.circle.badge.plus"
        case .sms: return "message"
        case .unknown: return "qrcode"
        }
    }
}

// MARK: - Enhanced Barcode Detection Manager
class BarcodeDetectionManager: BarcodeDetectionProtocol {
    
    func detectBarcodes(on image: UIImage, completion: @escaping ([VNBarcodeObservation]) -> Void) {
        guard let cgImage = image.cgImage else {
            completion([])
            return
        }

        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                print("Error detecting barcodes: \(error)")
                completion([])
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation] else {
                completion([])
                return
            }
            
            // Filter and prioritize QR codes
            let sortedResults = results.sorted { lhs, rhs in
                // Prioritize QR codes over other barcode types
                let lhsIsQR = lhs.symbology == .qr
                let rhsIsQR = rhs.symbology == .qr
                
                if lhsIsQR && !rhsIsQR { return true }
                if !lhsIsQR && rhsIsQR { return false }
                
                // Then sort by confidence
                return lhs.confidence > rhs.confidence
            }
            
            completion(sortedResults)
        }
        
        // Configure to detect multiple barcode types including QR codes
        request.symbologies = [
            .qr,
            .code128,
            .code39,
            .code93,
            .ean8,
            .ean13,
            .upce,
            .pdf417,
            .dataMatrix,
            .aztec
        ]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform barcode detection: \(error)")
            completion([])
        }
    }
    
    // MARK: - QR Code Content Analysis
    func parseQRCodeContent(_ payload: String) -> QRCodeContentType {
        let trimmedPayload = payload.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // URL detection
        if let url = URL(string: trimmedPayload),
           url.scheme != nil {
            return .url(url)
        }
        
        // Email detection
        if trimmedPayload.lowercased().hasPrefix("mailto:") {
            let email = String(trimmedPayload.dropFirst(7))
            return .email(email)
        }
        
        // Phone detection
        if trimmedPayload.lowercased().hasPrefix("tel:") {
            let phone = String(trimmedPayload.dropFirst(4))
            return .phone(phone)
        }
        
        // SMS detection
        if trimmedPayload.lowercased().hasPrefix("sms:") {
            let smsContent = String(trimmedPayload.dropFirst(4))
            let components = smsContent.components(separatedBy: "?body=")
            let number = components[0]
            let message = components.count > 1 ? components[1] : nil
            return .sms(number: number, message: message)
        }
        
        // WiFi detection
        if trimmedPayload.lowercased().hasPrefix("wifi:") {
            return parseWiFiQRCode(trimmedPayload)
        }
        
        // vCard detection
        if trimmedPayload.lowercased().hasPrefix("begin:vcard") {
            return .contact(vCard: trimmedPayload)
        }
        
        // Simple email pattern detection
        if isValidEmail(trimmedPayload) {
            return .email(trimmedPayload)
        }
        
        // Simple phone pattern detection
        if isValidPhoneNumber(trimmedPayload) {
            return .phone(trimmedPayload)
        }
        
        // URL without scheme
        if trimmedPayload.contains(".") && !trimmedPayload.contains(" ") {
            if let url = URL(string: "https://\(trimmedPayload)") {
                return .url(url)
            }
        }
        
        // Default to text
        return .text(trimmedPayload)
    }
    
    // MARK: - Private Helper Methods
    private func parseWiFiQRCode(_ payload: String) -> QRCodeContentType {
        // WiFi format: WIFI:T:WPA;S:NetworkName;P:Password;H:false;;
        let components = payload.components(separatedBy: ";")
        var ssid: String?
        var password: String?
        var security: String?
        
        for component in components {
            if component.hasPrefix("S:") {
                ssid = String(component.dropFirst(2))
            } else if component.hasPrefix("P:") {
                password = String(component.dropFirst(2))
            } else if component.hasPrefix("T:") {
                security = String(component.dropFirst(2))
            }
        }
        
        return .wifi(ssid: ssid ?? "Unknown Network", password: password, security: security)
    }
    
    private func isValidEmail(_ string: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return string.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    private func isValidPhoneNumber(_ string: String) -> Bool {
        let phoneRegex = #"^[\+]?[1-9][\d]{0,15}$"#
        let cleanedString = string.replacingOccurrences(of: "[^0-9+]", with: "", options: .regularExpression)
        return cleanedString.range(of: phoneRegex, options: .regularExpression) != nil
    }
}
