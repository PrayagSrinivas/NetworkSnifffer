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
    private var previousKeyWindow: UIWindow?
    private var buttonPosition = CGPoint(x: UIScreen.main.bounds.width - 80, y: UIScreen.main.bounds.height - 150)
    private var searchTimer: Timer?
    
    // Keep references to gestures so we can disable them
    private var panGesture: UIPanGestureRecognizer?
    private var tapGesture: UITapGestureRecognizer?
    
    func start() {
        searchTimer?.invalidate()
        if attemptToShowWindow() { return }
        searchTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            if self.attemptToShowWindow() {
                timer.invalidate()
            }
        }
    }
    
    private func attemptToShowWindow() -> Bool {
        if overlayWindow != nil { return true }
        
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        
        guard let windowScene = scene else { return false }
        setupWindow(in: windowScene)
        return true
    }
    
    private func setupWindow(in scene: UIWindowScene) {
        let window = UIWindow(windowScene: scene)
        window.frame = CGRect(x: buttonPosition.x, y: buttonPosition.y, width: 60, height: 60)
        window.backgroundColor = .clear
        window.windowLevel = .statusBar + 1
        
        let buttonView = FloatingDebuggerButton()
        let hostingController = UIHostingController(rootView: buttonView)
        hostingController.view.backgroundColor = .clear
        window.rootViewController = hostingController
        
        // Setup Gestures
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        window.addGestureRecognizer(pan)
        window.addGestureRecognizer(tap)
        
        // Save references
        self.panGesture = pan
        self.tapGesture = tap
        
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
        window.center = CGPoint(x: window.center.x + translation.x, y: window.center.y + translation.y)
        gesture.setTranslation(.zero, in: window)
        
        if gesture.state == .ended {
            let screen = UIScreen.main.bounds
            var finalX = max(30, min(screen.width - 30, window.center.x))
            var finalY = max(50, min(screen.height - 50, window.center.y))
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                window.center = CGPoint(x: finalX, y: finalY)
            }
            self.buttonPosition = window.frame.origin
        }
    }
    
    // MARK: - Presentation Logic
    
    func presentDebugger() {
        guard let window = overlayWindow, let rootVC = window.rootViewController else { return }
        
        // Safety Check: If already presented, stop immediately
        if rootVC.presentedViewController != nil { return }
        
        // 1. DISABLE Gestures (So tapping the list doesn't trigger this again)
        panGesture?.isEnabled = false
        tapGesture?.isEnabled = false
        
        self.previousKeyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        
        window.frame = UIScreen.main.bounds
        window.layoutIfNeeded()
        window.makeKeyAndVisible()
        
        rootVC.view.alpha = 0
        
        DispatchQueue.main.async {
            let debuggerView = NetworkDebuggerView()
            let hostingVC = DebuggerHostingController(rootView: debuggerView)
            hostingVC.modalPresentationStyle = .overFullScreen
            hostingVC.view.backgroundColor = .clear
            
            rootVC.present(hostingVC, animated: true)
        }
    }
    
    func minimizeWindow() {
        guard let window = overlayWindow, let rootVC = window.rootViewController else { return }
        
        // 1. Instant Snap (Remove UIView.animate)
        // Since the sheet is already gone, we don't need to animate the invisible window frame.
        window.frame = CGRect(x: self.buttonPosition.x, y: self.buttonPosition.y, width: 60, height: 60)
        
        // 2. Show Button Immediately
        rootVC.view.alpha = 1
        
        // 3. Return Focus to App Immediately
        self.previousKeyWindow?.makeKeyAndVisible()
        self.previousKeyWindow = nil
        
        // 4. Re-enable Gestures
        self.panGesture?.isEnabled = true
        self.tapGesture?.isEnabled = true
    }
}

class DebuggerHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // This triggers ONLY after the sheet has fully slid off screen.
        // It calls our new "Instant Snap" function, making the button pop back immediately.
        if isBeingDismissed {
            DebuggerWindowManager.shared.minimizeWindow()
        }
    }
}
