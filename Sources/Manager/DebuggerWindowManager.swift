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
    
    private var panGesture: UIPanGestureRecognizer?
    private var tapGesture: UITapGestureRecognizer?
    private var longPressGesture: UILongPressGestureRecognizer?
    
    private func hasLogs() -> Bool {
        return !NetworkLogger.shared.logs.isEmpty
    }
    
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
        
        // Gestures
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.5 // Faster response
        
        window.addGestureRecognizer(pan)
        window.addGestureRecognizer(tap)
        window.addGestureRecognizer(longPress)
        
        self.panGesture = pan
        self.tapGesture = tap
        self.longPressGesture = longPress
        
        window.isHidden = false
        self.overlayWindow = window
    }
    
    // MARK: - Gestures
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        presentDebugger()
    }

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            
            // Call the new menu presentation
            presentMenuOverlay()
        }
    }

        // MARK: - Gestures
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let window = overlayWindow else { return }
        
        let translation = gesture.translation(in: window)
        window.center = CGPoint(x: window.center.x + translation.x, y: window.center.y + translation.y)
        gesture.setTranslation(.zero, in: window)
        
        if gesture.state == .ended {
            let screen = UIScreen.main.bounds
            let buttonWidth: CGFloat = 60
            let safePadding: CGFloat = 35 // Distance from edge
            
            // 1. Determine Snap Target X
            // If we are past the middle, go right. Otherwise, go left.
            let isRightSide = window.center.x > screen.width / 2
            let finalX = isRightSide ? screen.width - safePadding : safePadding
            
            // 2. Clamp Y to keep it on screen vertically
            var finalY = window.center.y
            let minY = 50.0 + (window.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
            let maxY = screen.height - 50.0
            
            if finalY < minY { finalY = minY }
            if finalY > maxY { finalY = maxY }
            
            // 3. Animate the Snap
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                window.center = CGPoint(x: finalX, y: finalY)
            }
            
            // 4. Update stored position
            // IMPORTANT: We use the frame's origin (top-left) for storage, not center
            let originX = finalX - (buttonWidth / 2)
            let originY = finalY - (buttonWidth / 2)
            self.buttonPosition = CGPoint(x: originX, y: originY)
        }
    }
    
    // MARK: - Menu Presentation (NEW)
    private func presentMenuOverlay() {
        guard hasLogs() else { return }
        guard let window = overlayWindow, let rootVC = window.rootViewController else { return }
        if rootVC.presentedViewController != nil { return }

        // Disable gestures while menu is open
        panGesture?.isEnabled = false
        tapGesture?.isEnabled = false
        longPressGesture?.isEnabled = false
        
        // Expand window to full screen
        window.frame = UIScreen.main.bounds
        window.layoutIfNeeded()
        
        rootVC.view.alpha = 0 // Hide real button
        
        // Pass the CURRENT position to the overlay so it draws in the right spot
        // Note: buttonPosition is the Top-Left origin.
        let menuView = DebuggerMenuOverlay(buttonPosition: self.buttonPosition) {
            // Dismiss Callback
            rootVC.dismiss(animated: false, completion: nil)
        }
        
        let hostingVC = DebuggerHostingController(rootView: menuView)
        hostingVC.modalPresentationStyle = .overFullScreen
        hostingVC.view.backgroundColor = .clear
        
        // Present without animation (SwiftUI handles the pop-out animation)
        rootVC.present(hostingVC, animated: false)
    }
    
    // MARK: - Dashboard Presentation
    func presentDebugger() {
        guard hasLogs() else { return }
        guard let window = overlayWindow, let rootVC = window.rootViewController else { return }
        if rootVC.presentedViewController != nil { return }
        
        panGesture?.isEnabled = false
        tapGesture?.isEnabled = false
        longPressGesture?.isEnabled = false
        
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
        
        // Instant Snap Back
        window.frame = CGRect(x: self.buttonPosition.x, y: self.buttonPosition.y, width: 60, height: 60)
        
        rootVC.view.alpha = 1
        self.previousKeyWindow?.makeKeyAndVisible()
        self.previousKeyWindow = nil
        
        self.panGesture?.isEnabled = true
        self.tapGesture?.isEnabled = true
        self.longPressGesture?.isEnabled = true
    }
}

// Controller helper remains the same
class DebuggerHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            DebuggerWindowManager.shared.minimizeWindow()
        }
    }
}

