//
//  ContentView.swift
//  NetworkSnifferDemo
//
//  Main UI for the demo app with API testing buttons
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NetworkDemoViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "network")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("NetworkSniffer Demo")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Tap buttons to test API calls")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // API Test Buttons
                VStack(spacing: 16) {
                    // GET Request
                    APIButton(
                        title: "GET Request",
                        icon: "arrow.down.circle.fill",
                        color: .blue,
                        isLoading: viewModel.isLoadingGet
                    ) {
                        await viewModel.testGetRequest()
                    }
                    
                    // POST Request
                    APIButton(
                        title: "POST Request",
                        icon: "arrow.up.circle.fill",
                        color: .green,
                        isLoading: viewModel.isLoadingPost
                    ) {
                        await viewModel.testPostRequest()
                    }
                    
                    // PUT Request
                    APIButton(
                        title: "PUT Request",
                        icon: "arrow.triangle.2.circlepath",
                        color: .orange,
                        isLoading: viewModel.isLoadingPut
                    ) {
                        await viewModel.testPutRequest()
                    }
                    
                    // DELETE Request
                    APIButton(
                        title: "DELETE Request",
                        icon: "trash.circle.fill",
                        color: .red,
                        isLoading: viewModel.isLoadingDelete
                    ) {
                        await viewModel.testDeleteRequest()
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Status Display
                if let lastResponse = viewModel.lastResponse {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Last Response:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(lastResponse)
                            .font(.caption)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Info text
                Text("Check the NetworkSniffer overlay for detailed logs")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// Custom Button Component
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
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.headline)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isLoading ? color.opacity(0.6) : color)
            .cornerRadius(12)
        }
        .disabled(isLoading)
    }
}

#Preview {
    ContentView()
}
