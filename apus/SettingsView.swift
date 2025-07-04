//
//  SettingsView.swift
//  apus
//
//  Created by Chan Wai Chan on 29/6/2025.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            Spacer()
            
            Text("Settings page content will go here")
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
