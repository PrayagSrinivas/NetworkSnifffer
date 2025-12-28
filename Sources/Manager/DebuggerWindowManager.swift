//
//  DebuggerWindowManager.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 28/12/25.
//


import UIKit
import SwiftUI

@MainActor
class DebuggerWindowManager: NSObject, ObservableObject, UIPopoverPresentationControllerDelegate {
    static let shared = DebuggerWindowManager()
    
    private var overlayWindow: UIWindow?
    private var previousKeyWindow: UIWindow?
    private var buttonPosition = CGPoint(x: UIScreen.main.bounds.width - 80, y: UIScreen.main.bounds.height - 150)
    private var searchTimer: Timer?
    
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
        
        // Gestures
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 0.8
        
        window.addGestureRecognizer(pan)
        window.addGestureRecognizer(tap)
        window.addGestureRecognizer(longPress)
        
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

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            presentClearLogsAlert()
        }
    }
    
    // MARK: - Alert Logic (FIXED)
    private func presentClearLogsAlert() {
        guard let window = overlayWindow, let rootVC = window.rootViewController else { return }
        
        // 1. Expand Window to Full Screen (Fixes Clipping)
        self.previousKeyWindow = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
            
        window.frame = UIScreen.main.bounds
        window.layoutIfNeeded()
        
        // 2. Create Alert
        let alert = UIAlertController(
            title: "Clear Logs?",
            message: "This will delete all captured network traffic.",
            preferredStyle: .actionSheet
        )
        
        // 3. Handle Actions (Shrink window back when done)
        let deleteAction = UIAlertAction(title: "Delete All", style: .destructive) { [weak self] _ in
            Task { @MainActor in
                NetworkLogger.shared.clearLogs()
                self?.minimizeWindow()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.minimizeWindow()
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        // 4. iPad Support (Popover)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = rootVC.view
            popoverController.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
            popoverController.delegate = self // Handle tap-outside dismissal
        }
        
        rootVC.present(alert, animated: true, completion: nil)
    }
    
    // Handle tapping outside the popover on iPad
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        minimizeWindow()
    }
    
    // MARK: - Dashboard Presentation
    func presentDebugger() {
        guard let window = overlayWindow, let rootVC = window.rootViewController else { return }
        if rootVC.presentedViewController != nil { return }
        
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
        
        // Instant Snap Back
        window.frame = CGRect(x: self.buttonPosition.x, y: self.buttonPosition.y, width: 60, height: 60)
        
        rootVC.view.alpha = 1
        self.previousKeyWindow?.makeKeyAndVisible()
        self.previousKeyWindow = nil
        
        self.panGesture?.isEnabled = true
        self.tapGesture?.isEnabled = true
    }
}

class DebuggerHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            DebuggerWindowManager.shared.minimizeWindow()
        }
    }
}
