//
//  DebuggerMenuOverlay.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 28/12/25.
//


import SwiftUI

struct DebuggerMenuOverlay: View {
    let buttonPosition: CGPoint
    let onDismiss: () -> Void
    
    @ObservedObject var logger = NetworkLogger.shared
    @Environment(\.colorScheme) private var colorScheme
    @State private var showMenu = false
    
    // Determine which side the button is on
    var isRightSide: Bool {
        return buttonPosition.x > UIScreen.main.bounds.width / 2
    }
    
    var body: some View {
        ZStack {
            // Background Tap to Dismiss
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { closeMenu() }
            
            ZStack {
                // Direction multiplier: -1 if on right (move left), 1 if on left (move right)
                let direction: CGFloat = isRightSide ? -1 : 1
                let hasLogs = !logger.logs.isEmpty
                
                // --- TRASH BUTTON (Top-Diagonal) ---
                if showMenu {
                    Button(action: {
                        logger.clearLogs()
                        closeMenu()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                            .shadow(radius: 3)
                            .overlay(Image(systemName: "trash").foregroundColor(.red))
                    }
                    // Offset: Move Inwards (X) and Up (Y)
                    .offset(x: 70 * direction, y: -40)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // --- CLOSE BUTTON (Bottom-Diagonal) ---
                if showMenu {
                    Button(action: {
                        closeMenu()
                    }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 44, height: 44)
                            .shadow(radius: 3)
                            .overlay(Image(systemName: "xmark").foregroundColor(.black))
                    }
                    // Offset: Move Inwards (X) and Down (Y)
                    .offset(x: 70 * direction, y: 40)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // --- MAIN ANCHOR (Visual Only) ---
                ZStack {
                    ThemedNetworkIcon(size: 50, iconSize: 24, hasBackground: true)
                        .overlay(Circle().stroke(Color.green, lineWidth: 2))
                }
                .opacity(hasLogs ? 1 : 0.4)
                .allowsHitTesting(hasLogs)
                .onTapGesture { if hasLogs { closeMenu() } }
            }
            // Position exactly where the real button is
            .position(x: buttonPosition.x + 30, y: buttonPosition.y + 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                showMenu = true
            }
        }
    }
    
    func closeMenu() {
        withAnimation {
            showMenu = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}

