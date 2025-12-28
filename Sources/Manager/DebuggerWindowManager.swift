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
        guard overlayWindow == nil else { return }
        
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
            return
        }
        
        let window = DebuggerWindow(windowScene: scene)
        window.frame = UIScreen.main.bounds
        window.backgroundColor = .clear
        window.windowLevel = .statusBar + 1
        
        let buttonView = FloatingDebuggerButton()
        let hostingController = UIHostingController(rootView: buttonView)
        hostingController.view.backgroundColor = .clear
        
        window.rootViewController = hostingController
        window.isHidden = false
        
        self.overlayWindow = window
    }
    
    func presentDebugger() {
        guard let rootVC = overlayWindow?.rootViewController else { return }
        
        // Prevent double presentation
        if rootVC.presentedViewController is UIHostingController<NetworkDebuggerView> {
            return
        }
        
        // Create the Debugger UI
        let debuggerView = NetworkDebuggerView()
        let hostingVC = UIHostingController(rootView: debuggerView)
        hostingVC.modalPresentationStyle = .fullScreen
        
        // Present strictly from our own Overlay Window
        rootVC.present(hostingVC, animated: true)
    }
}
