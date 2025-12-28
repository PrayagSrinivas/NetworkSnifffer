//
//  FloatingDebuggerButton.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 28/12/25.
//


import SwiftUI

public struct FloatingDebuggerButton: View {
    @ObservedObject var logger = NetworkLogger.shared
    
    // CHANGED: Use CGPoint instead of CGSize for absolute positioning
    @State private var position: CGPoint = CGPoint(
        x: UIScreen.main.bounds.width - 60,
        y: UIScreen.main.bounds.height - 200
    )
    
    public init() {}
    
    public var body: some View {
        GeometryReader { geometry in
            Button(action: {
                presentDashboard()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.8))
                        .frame(width: 50, height: 50)
                        .shadow(radius: 5)
                        .overlay(
                            Circle().stroke(Color.green, lineWidth: 2)
                        )
                    
                    Image(systemName: "network")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                    
                    if logger.logs.count > 0 {
                        Text("\(logger.logs.count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 15, y: -15)
                    }
                }
            }
            // FIX: Use .position with the CGPoint directly
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        // FIX: Now we can assign CGPoint directly to CGPoint
                        self.position = gesture.location
                    }
                    .onEnded { gesture in
                        // Optional: Keep it inside screen bounds
                        withAnimation {
                            var newX = gesture.location.x
                            var newY = gesture.location.y
                            
                            // Simple boundary checks
                            if newX < 30 { newX = 30 }
                            if newX > geometry.size.width - 30 { newX = geometry.size.width - 30 }
                            if newY < 50 { newY = 50 }
                            if newY > geometry.size.height - 50 { newY = geometry.size.height - 50 }
                            
                            self.position = CGPoint(x: newX, y: newY)
                        }
                    }
            )
        }
    }
    
    func presentDashboard() {
        // We need to find the top-most view controller to present the sheet
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }
        
        // Prevent double presentation
        if rootVC.presentedViewController is UIHostingController<NetworkDebuggerView> { return }
        
        let debuggerView = NetworkDebuggerView()
        let hostingVC = UIHostingController(rootView: debuggerView)
        hostingVC.modalPresentationStyle = .fullScreen
        
        rootVC.present(hostingVC, animated: true)
    }
}
