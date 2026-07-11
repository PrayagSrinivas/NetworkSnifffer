//
//  ContentView.swift
//  NetworkSnifferDemo
//
//  Main UI for the demo app with API testing buttons and live debugger launch
//

import SwiftUI
import NetworkSnifffer

struct ContentView: View {
    @StateObject private var viewModel = NetworkDemoViewModel()
    @ObservedObject private var logger = NetworkLogger.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Pitch Black Background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Header Area
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "network")
                                .font(.system(size: 38))
                                .foregroundColor(.white)
                                .shadow(color: .white.opacity(0.2), radius: 6)
                        }
                        
                        Text("NetworkSniffer Demo")
                            .font(.system(.title, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Test API requests and inspect real-time logs")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.6))
                    }
                    .padding(.top, 30)
                    
                    Spacer()
                    
                    // Main Actions Section
                    VStack(spacing: 14) {
                        // GET & POST Requests (HStack)
                        HStack(spacing: 14) {
                            APIButton(
                                title: "GET Post",
                                icon: "arrow.down.circle.fill",
                                color: .white,
                                isLoading: viewModel.isLoadingGet
                            ) {
                                await viewModel.testGetRequest()
                            }
                            
                            APIButton(
                                title: "POST Post",
                                icon: "arrow.up.circle.fill",
                                color: .white,
                                isLoading: viewModel.isLoadingPost
                            ) {
                                await viewModel.testPostRequest()
                            }
                        }
                        
                        // PUT & DELETE Requests (HStack)
                        HStack(spacing: 14) {
                            APIButton(
                                title: "PUT Post",
                                icon: "arrow.triangle.2.circlepath",
                                color: .white,
                                isLoading: viewModel.isLoadingPut
                            ) {
                                await viewModel.testPutRequest()
                            }
                            
                            APIButton(
                                title: "DELETE Post",
                                icon: "trash.circle.fill",
                                color: .white,
                                isLoading: viewModel.isLoadingDelete
                            ) {
                                await viewModel.testDeleteRequest()
                            }
                        }
                        
                        // GET Error (404) Button (Minimal Monochrome style)
                        APIButton(
                            title: "GET Error (404)",
                            icon: "exclamationmark.triangle.fill",
                            color: .white,
                            isLoading: viewModel.isLoadingError
                        ) {
                            await viewModel.testErrorRequest()
                        }
                        
                        Divider()
                            .background(Color.white.opacity(0.15))
                            .padding(.vertical, 8)
                        
                        // AUTO-RUN SUITE BUTTON (Solid White with Black Text)
                        Button {
                            Task {
                                await runDemoSuite()
                            }
                        } label: {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title3)
                                Text("Auto-Run Full API Suite")
                                    .font(.system(.headline, design: .rounded))
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(.black)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(14)
                            .shadow(color: Color.white.opacity(0.1), radius: 6)
                        }
                        
                        // DIRECT LAUNCH DASHBOARD
                        Button {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                logger.isDashboardPresented = true
                            }
                        } label: {
                            HStack {
                                Image(systemName: "ladybug.fill")
                                Text("Open Inspector Dashboard")
                                    .font(.system(.subheadline, design: .rounded))
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Status Output Panel
                    if let lastResponse = viewModel.lastResponse {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("CONSOLE OUTPUT")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.6))
                            
                            Text(lastResponse)
                                .font(.system(.caption, design: .monospaced))
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(white: 0.08))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                )
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }
                    
                    Spacer()
                    
                    // Floating button instruction
                    Text("Or tap / drag the floating debugger button to inspect logs")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(Color.white.opacity(0.5))
                        .padding(.bottom, 16)
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(.stack)
        .fullScreenCover(isPresented: $logger.isDashboardPresented) {
            NetworkDebuggerView()
        }
        .onAppear {
            // Check if launched under automated screenshot runner mode
            if ProcessInfo.processInfo.environment["AUTO_RUN_DEMO"] == "1" {
                Task {
                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1s delay
                    await runDemoSuite()
                }
            }
        }
    }
    
    // Auto-run sequence helper
    private func runDemoSuite() async {
        await viewModel.testGetRequest()
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        await viewModel.testPostRequest()
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        await viewModel.testPutRequest()
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        await viewModel.testDeleteRequest()
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        await viewModel.testErrorRequest()
        try? await Task.sleep(nanoseconds: 800_000_000)
        
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
            logger.isDashboardPresented = true
        }
    }
}

// Custom Styled Button Component (Monochrome style)
struct APIButton: View {
    let title: String
    let icon: String
    let color: Color
    let isLoading: Bool
    let action: () async -> Void
    
    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: icon)
                        .font(.subheadline)
                }
                
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(isLoading ? 0.2 : 0.4), lineWidth: 1.5)
            )
            .shadow(color: Color.white.opacity(0.02), radius: 4, x: 0, y: 2)
        }
        .disabled(isLoading)
    }
}

#Preview {
    ContentView()
}
