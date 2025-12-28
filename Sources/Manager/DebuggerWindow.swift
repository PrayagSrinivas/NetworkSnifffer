//
//  DebuggerWindow.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 28/12/25.
//


import UIKit

class DebuggerWindow: UIWindow {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // Get the view that was tapped
        let hitView = super.hitTest(point, with: event)
        
        // If the tapped view is the Root View (the empty background),
        // return nil to let the touch pass through to the main app window.
        if hitView == rootViewController?.view {
            return nil
        }
        
        // If it's the button (or any subview), return it so the button works.
        return hitView
    }
}