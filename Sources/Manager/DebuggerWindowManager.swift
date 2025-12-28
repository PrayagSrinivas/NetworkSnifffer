//
//  DebuggerWindowManager.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 28/12/25.
//


import UIKit
import SwiftUI

@MainActor
class DebuggerWindowManager: ObservableObject {
    static let shared = DebuggerWindowManager()
    
    private var overlayWindow: DebuggerWindow?
    
    func show() {
        // Prevent creating multiple windows
        guard overlayWindow == nil else { return }
        
        // Find the active window scene (iOS 13+)
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }
        
        // Create the transparent overlay window
        let window = DebuggerWindow(windowScene: scene)
        window.frame = UIScreen.main.bounds
        window.backgroundColor = .clear
        window.windowLevel = .statusBar + 1 // Ensure it sits above everything
        
        // Host the Floating Button
        let buttonView = FloatingDebuggerButton()
        let hostingController = UIHostingController(rootView: buttonView)
        hostingController.view.backgroundColor = .clear // Make SwiftUI background clear
        
        window.rootViewController = hostingController
        window.isHidden = false
        
        self.overlayWindow = window
    }
}