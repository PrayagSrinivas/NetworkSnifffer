//
//  FloatingDebuggerButton.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 28/12/25.
//

import SwiftUI

public struct FloatingDebuggerButton: View {
    @ObservedObject var logger = NetworkLogger.shared
    var hasLogs: Bool { !logger.logs.isEmpty }
    
    public init() {}
    
    public var body: some View {
        // NO BUTTON HERE. Just the visual elements.
        // Taps are handled by the Window Manager now.
        ZStack {
            ThemedNetworkIcon(size: 50, iconSize: 24, hasBackground: true)
                .shadow(radius: 5)
                .overlay(
                    Circle().stroke(Color.green, lineWidth: 2)
                )
            
            if logger.logs.count > 0 {
                Text("\(logger.logs.count)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 15, y: -15)
            }
        }
        .opacity(hasLogs ? 1 : 0.4)
    }
}

