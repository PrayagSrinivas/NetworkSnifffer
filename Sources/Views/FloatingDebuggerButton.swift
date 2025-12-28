//
//  FloatingDebuggerButton.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 28/12/25.
//


import SwiftUI

struct FloatingDebuggerButton: View {
    @ObservedObject var logger = NetworkLogger.shared
    @State private var offset = CGSize(width: UIScreen.main.bounds.width - 70, height: UIScreen.main.bounds.height - 200)
    
    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                presentDashboard()
            }) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.8)) // Dark theme button
                        .frame(width: 50, height: 50)
                        .shadow(radius: 5)
                        .overlay(
                            Circle().stroke(Color.green, lineWidth: 2)
                        )
                    
                    Image(systemName: "network")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                    
                    // Badge
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
            .position(x: 25, y: 25) // Center pivot
            .offset(x: offset.width, y: offset.height)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        self.offset = gesture.location
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
