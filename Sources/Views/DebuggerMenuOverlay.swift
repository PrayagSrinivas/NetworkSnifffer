//
//  DebuggerMenuOverlay.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 28/12/25.
//


import SwiftUI

struct DebuggerMenuOverlay: View {
    // The exact position where the floating button currently sits
    let buttonPosition: CGPoint
    let onDismiss: () -> Void
    
    @ObservedObject var logger = NetworkLogger.shared
    @State private var showMenu = false
    
    var body: some View {
        ZStack {
            // 1. Tappable Background (Closes the menu)
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    closeMenu()
                }
            
            // 2. The Menu Cluster
            ZStack {
                // --- TRASH BUTTON (Left) ---
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
                    .offset(x: -60, y: -10) // Pop out to the left
                    .transition(.scale.combined(with: .opacity))
                }
                
                // --- CLOSE BUTTON (Right) ---
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
                    .offset(x: 60, y: -10) // Pop out to the right
                    .transition(.scale.combined(with: .opacity))
                }
                
                // --- MAIN ANCHOR BUTTON ---
                // This sits exactly where the floating button was, 
                // creating the illusion that the button just "activated".
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.8))
                        .frame(width: 50, height: 50)
                        .overlay(Circle().stroke(Color.green, lineWidth: 2))
                    
                    Image(systemName: "network")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }
                .onTapGesture {
                    closeMenu() // Tapping main button also closes
                }
            }
            .position(x: buttonPosition.x + 30, y: buttonPosition.y + 30) // Offset for radius
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
        // Delay dismissal slightly to allow animation to finish
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            onDismiss()
        }
    }
}