//
//  SharedSettingsComponents.swift
//  apus
//
//  Created by Codex on 23/8/2025.
//

import SwiftUI

/// Reusable Settings toggle row with icon, title, subtitle, and trailing toggle
struct SettingsToggleRow: View {
    let systemImage: String
    let tint: Color
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(tint)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

/// Reusable Settings value row with icon, title and trailing value
struct SettingsValueRow: View {
    let systemImage: String
    let tint: Color
    let title: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(tint)
                .frame(width: 24, height: 24)

            Text(title)

            Spacer()

            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

/// Reusable Settings header row with icon, title and subtitle (no trailing control)
struct SettingsHeaderRow: View {
    let systemImage: String
    let tint: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(tint)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

/// Reusable Settings action row (full-row button) with optional destructive styling and confirmation
struct SettingsActionRow: View {
    let systemImage: String
    let tint: Color
    let title: String
    var destructive: Bool = false
    // Optional confirmation
    var confirmTitle: String?
    var confirmMessage: String?
    var confirmButtonTitle: String = "Confirm"
    var cancelButtonTitle: String = "Cancel"
    let action: () -> Void

    @State private var showConfirm = false

    var body: some View {
        Button(role: destructive ? .destructive : nil) {
            if confirmTitle != nil {
                showConfirm = true
            } else {
                action()
            }
        } label: {
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(tint)
                    .frame(width: 24, height: 24)

                Text(title)
                    .foregroundColor(destructive ? .red : .primary)

                Spacer()
            }
        }
        .buttonStyle(PlainButtonStyle())
        .alert(confirmTitle ?? "", isPresented: $showConfirm) {
            Button(cancelButtonTitle, role: .cancel) { }
            Button(confirmButtonTitle, role: destructive ? .destructive : nil) {
                action()
            }
        } message: {
            if let msg = confirmMessage {
                Text(msg)
            }
        }
    }
}
