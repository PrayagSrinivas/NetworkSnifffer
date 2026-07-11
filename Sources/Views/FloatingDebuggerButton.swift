//
//  FloatingDebuggerButton.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 28/12/25.
//

import SwiftUI

public struct FloatingDebuggerButton: View {
    @ObservedObject var logger = NetworkLogger.shared
    @State private var pulseScale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.6
    
    var hasLogs: Bool { !logger.logs.isEmpty }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Monochrome Pulsing Halo (Only animates if there are logs)
            if hasLogs {
                Circle()
                    .stroke(Color.white.opacity(0.4), lineWidth: 2)
                    .frame(width: 54, height: 54)
                    .scaleEffect(pulseScale)
                    .opacity(pulseOpacity)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: false)
                        ) {
                            pulseScale = 1.4
                            pulseOpacity = 0.0
                        }
                    }
            }
            
            // Main Button Base (Minimalist Pitch Black with White Border)
            Circle()
                .fill(Color.black)
                .frame(width: 50, height: 50)
                .shadow(color: Color.white.opacity(0.15), radius: 6, x: 0, y: 3)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                )
            
            // White network icon
            Image(systemName: "network")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .shadow(color: Color.white.opacity(0.3), radius: 4)
            
            // Badge for unread requests (Solid White with Black Text)
            if logger.logs.count > 0 {
                Text("\(logger.logs.count)")
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                    .frame(minWidth: 16, minHeight: 16)
                    .padding(3)
                    .background(
                        Capsule()
                            .fill(Color.white)
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .shadow(color: Color.white.opacity(0.3), radius: 3, x: 1, y: 1)
                    .offset(x: 15, y: -15)
            }
        }
        .opacity(logger.isDashboardPresented ? 0.0 : (hasLogs ? 1.0 : 0.5))
        .allowsHitTesting(!logger.isDashboardPresented)
    }
}
