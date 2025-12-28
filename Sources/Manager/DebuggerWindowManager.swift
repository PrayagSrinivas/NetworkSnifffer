//
//  DebuggerWindowManager.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 28/12/25.
//


import UIKit
import SwiftUI

@MainActor
class DebuggerWindowManager: NSObject, ObservableObject {
    static let shared = DebuggerWindowManager()
    
    private var overlayWindow: UIWindow?
    // Start position: Bottom-right corner (safe area aware)
    private var buttonPosition = CGPoint(x: UIScreen.main.bounds.width - 80, y: UIScreen.main.bounds.height - 150)
    
    // Retry timer to find the window scene
    private var searchTimer: Timer?
    
    func start() {
        // Stop any existing timer
        searchTimer?.invalidate()
        
        // Try to find the scene immediately
        if attemptToShowWindow() { return }
        
        // If fail, retry every 0.1s until the app is fully active
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.attemptToShowWindow() {
                timer.invalidate()
            }
        }
    }
    
    private func attemptToShowWindow() -> Bool {
        // Prevent duplicates
        if overlayWindow != nil { return true }
        
        // robustly find the active scene
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        
        guard let windowScene = scene else { return false }
        
        setupWindow(in: windowScene)
        return true
    }
    
    private func setupWindow(in scene: UIWindowScene) {
        // 1. Create Small Window (60x60)
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: buttonPosition.x, y: buttonPosition.y, width: 60, height: 60)
        window.backgroundColor = .clear
        window.windowLevel = .statusBar + 1 // Always on top
        
        // 2. Setup SwiftUI View (Visual Only - No Button Action)
        let buttonView = FloatingDebuggerButton()
        let hostingController = UIHostingController(rootView: buttonView)
        hostingController.view.backgroundColor = .clear
        window.rootViewController = hostingController
        
        // 3. Add Gestures DIRECTLY to the Window (Solves Simulator Issue)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        window.addGestureRecognizer(panGesture)
        window.addGestureRecognizer(tapGesture)
        
        window.isHidden = false
        self.overlayWindow = window
    }
    
    // MARK: - Gestures
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        presentDebugger()
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let window = overlayWindow else { return }
        
        let translation = gesture.translation(in: window)
        // Move the window center
        let newCenter = CGPoint(x: window.center.x + translation.x, y: window.center.y + translation.y)
        
        window.center = newCenter
        gesture.setTranslation(.zero, in: window)
        
        if gesture.state == .ended {
            // Keep the window within screen bounds
            let screen = UIScreen.main.bounds
            var finalX = window.center.x
            var finalY = window.center.y
            
            // Clamp X
            if finalX < 30 { finalX = 30 }
            if finalX > screen.width - 30 { finalX = screen.width - 30 }
            
            // Clamp Y
            if finalY < 50 { finalY = 50 }
            if finalY > screen.height - 50 { finalY = screen.height - 50 }
            
            UIView.animate(withDuration: 0.3) {
                window.center = CGPoint(x: finalX, y: finalY)
            }
            
            // Save position so it remembers where it was if we minimize later
            self.buttonPosition = window.frame.origin
        }
    }
    
    // MARK: - Presentation
    
    func presentDebugger() {
        guard let window = overlayWindow, let rootVC = window.rootViewController else { return }
        
        // 1. Expand Window to Full Screen
        UIView.animate(withDuration: 0.2) {
            window.frame = UIScreen.main.bounds
        }
        
        // 2. Present Modal
        let debuggerView = NetworkDebuggerView()
        let hostingVC = DebuggerHostingController(rootView: debuggerView)
        hostingVC.modalPresentationStyle = .fullScreen
        rootVC.present(hostingVC, animated: true)
    }
    
    func minimizeWindow() {
        guard let window = overlayWindow else { return }
        
        // Shrink back to button size
        UIView.animate(withDuration: 0.3) {
            window.frame = CGRect(x: self.buttonPosition.x, y: self.buttonPosition.y, width: 60, height: 60)
        }
    }
}

// Helper to detect dismissal
class DebuggerHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            DebuggerWindowManager.shared.minimizeWindow()
        }
    }
}
