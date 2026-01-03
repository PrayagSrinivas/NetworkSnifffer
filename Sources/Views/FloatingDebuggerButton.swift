//
//  FloatingDebuggerButton.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 28/12/25.
//


import SwiftUI

public struct FloatingDebuggerButton: View {
    @ObservedObject var logger = NetworkLogger.shared
    
    public init() {}
    
    public var body: some View {
        Button(action: {
            // Only toggle if we actually have logs
            if !logger.logs.isEmpty {
                logger.isDashboardPresented.toggle()
            }
        }) {
            Image(systemName: "ladybug.fill") // "Modern" bug icon
                .font(.system(size: 24, weight: .semibold))
            // Adaptive Colors: White icon on Black text (and vice versa)
                .foregroundColor(Color(UIColor.systemBackground))
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                    // Adaptive Background: Black in Light Mode, White in Dark Mode
                        .fill(Color.primary)
                        .shadow(color: Color.black.opacity(0.3), radius: 6, x: 0, y: 4)
                )
        }
        // UX 1: Disable interaction if no logs
        .disabled(logger.logs.isEmpty)
        // UX 2: Grey out ("Ghost") the button if no logs
        .opacity(logger.logs.isEmpty ? 0.4 : 1.0)
        // Animation for smooth state changes
        .animation(.spring(), value: logger.logs.isEmpty)
        .padding()
    }
}
