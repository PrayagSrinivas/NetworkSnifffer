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
    
    private var overlayWindow: UIWindow?
    private var buttonPosition: CGPoint = CGPoint(x: UIScreen.main.bounds.width - 70, y: UIScreen.main.bounds.height - 200)
    
    func show() {
        guard overlayWindow == nil else { return }
        
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        
        // 1. Create a SMALL window (Button size only)
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: buttonPosition.x, y: buttonPosition.y, width: 60, height: 60)
        window.backgroundColor = .clear
        window.windowLevel = .statusBar + 1
        
        // 2. Setup the Button
        let buttonView = FloatingDebuggerButton()
        let hostingController = UIHostingController(rootView: buttonView)
        hostingController.view.backgroundColor = .clear
        
        window.rootViewController = hostingController
        window.isHidden = false
        
        // 3. Add Drag Gesture to move the WINDOW, not the view
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        window.addGestureRecognizer(panGesture)
        
        self.overlayWindow = window
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let window = overlayWindow else { return }
        
        let translation = gesture.translation(in: window)
        var newCenter = CGPoint(x: window.center.x + translation.x, y: window.center.y + translation.y)
        
        // Boundary checks (Keep button on screen)
        let screen = UIScreen.main.bounds
        newCenter.x = max(30, min(screen.width - 30, newCenter.x))
        newCenter.y = max(50, min(screen.height - 50, newCenter.y))
        
        window.center = newCenter
        gesture.setTranslation(.zero, in: window)
        
        // Save position for later
        if gesture.state == .ended {
            self.buttonPosition = window.frame.origin
        }
    }
    
    func presentDebugger() {
        guard let window = overlayWindow, let rootVC = window.rootViewController else { return }
        
        // 1. Expand Window to Full Screen to show the modal
        UIView.animate(withDuration: 0.2) {
            window.frame = UIScreen.main.bounds
        }
        
        // 2. Present the Dashboard
        let debuggerView = NetworkDebuggerView()
        // Wrap in a HostingController that knows how to dismiss itself
        let hostingVC = DebuggerHostingController(rootView: debuggerView)
        hostingVC.modalPresentationStyle = .fullScreen
        
        rootVC.present(hostingVC, animated: true)
    }
    
    // Called when the dashboard is closed
    func minimizeWindow() {
        guard let window = overlayWindow else { return }
        
        // Shrink back to button size
        UIView.animate(withDuration: 0.3) {
            window.frame = CGRect(x: self.buttonPosition.x, y: self.buttonPosition.y, width: 60, height: 60)
        }
    }
}

// Custom Controller to handle dismissal callbacks
class DebuggerHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Verify we are actually dismissing, not just covered
        if isBeingDismissed {
            DebuggerWindowManager.shared.minimizeWindow()
        }
    }
}
