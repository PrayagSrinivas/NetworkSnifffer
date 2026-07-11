//
//  NetworkDebuggerView.swift
//  NetworkCall
//
//  Created by Srinivas Prayag Sahu on 26/12/25.
//

import SwiftUI

public struct NetworkDebuggerView: View {
    @ObservedObject var logger = NetworkLogger.shared
    @State private var searchText = ""
    @State private var selectedMethods: Set<String> = []
    @State private var selectedStatus: Set<String> = [] // "success" or "failure"
    @State private var activeLogDetail: NetworkTraffic? = nil
    
    // Filter logic
    var filteredLogs: [NetworkTraffic] {
        var logs = logger.logs
        
        // Apply search filter
        if !searchText.isEmpty {
            logs = logs.filter { $0.url.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Apply method filter
        if !selectedMethods.isEmpty {
            logs = logs.filter { selectedMethods.contains($0.method) }
        }
        
        // Apply status filter
        if !selectedStatus.isEmpty {
            logs = logs.filter { log in
                guard let code = log.statusCode else { return false }
                
                if selectedStatus.contains("success") && code >= 200 && code < 400 {
                    return true
                }
                if selectedStatus.contains("failure") && code >= 400 {
                    return true
                }
                return false
            }
        }
        
        return logs
    }
    
    var hasActiveFilters: Bool {
        !selectedMethods.isEmpty || !selectedStatus.isEmpty || !searchText.isEmpty
    }
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Pitch Black Background
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Glowing Search Bar
                    CustomSearchBar(text: $searchText)
                    
                    // Scrolling Filter Pills
                    HorizontalFilterSection(
                        selectedMethods: $selectedMethods,
                        selectedStatus: $selectedStatus
                    )
                    
                    // Results Listing or Empty State
                    if filteredLogs.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle" : "network")
                                .font(.system(size: 64))
                                .foregroundColor(.white.opacity(0.4))
                            
                            Text(hasActiveFilters ? "No matches found" : "No captured traffic yet")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text(hasActiveFilters ? "Try clearing search filters." : "Interact with your app's APIs to inspect live requests.")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            if hasActiveFilters {
                                Button(action: clearFilters) {
                                    Text("Reset Filters")
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 18)
                                        .padding(.vertical, 8)
                                        .background(Capsule().fill(Color.white))
                                }
                                .padding(.top, 8)
                            }
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 2) {
                                ForEach(filteredLogs) { log in
                                    NavigationLink(destination: LogDetailView(log: log)) {
                                        LogCardView(log: log)
                                    }
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .bottom).combined(with: .opacity),
                                        removal: .opacity
                                    ))
                                }
                            }
                            .padding(.top, 8)
                            .padding(.bottom, 20)
                        }
                    }
                }
                
                // Invisible navigation link for automated demo mode
                NavigationLink(
                    destination: Group {
                        if let log = activeLogDetail {
                            LogDetailView(log: log)
                        }
                    },
                    isActive: Binding(
                        get: { activeLogDetail != nil },
                        set: { if !$0 { activeLogDetail = nil } }
                    )
                ) {
                    EmptyView()
                }
            }
            .navigationTitle("Network Sniffer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        NetworkLogger.shared.isDashboardPresented = false
                        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?
                            .rootViewController?.dismiss(animated: true, completion: nil)
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color(white: 0.15))
                            .clipShape(Circle())
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !logger.logs.isEmpty {
                        Button(action: {
                            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                                logger.clearLogs()
                                clearFilters()
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .onAppear {
                NetworkLogger.shared.isDashboardPresented = true
            }
            .onDisappear {
                NetworkLogger.shared.isDashboardPresented = false
            }
        }
        .colorScheme(.dark)
    }
    
    private func clearFilters() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            selectedMethods.removeAll()
            selectedStatus.removeAll()
            searchText = ""
        }
    }
}

// MARK: - Custom Card View
struct LogCardView: View {
    let log: NetworkTraffic
    
    private var statusColor: Color {
        guard let code = log.statusCode else { return .gray }
        if code >= 200 && code < 400 { return Color(red: 0.2, green: 0.85, blue: 0.55) } // High-readability emerald green
        return Color(red: 0.94, green: 0.27, blue: 0.27) // High-readability coral red
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Method Badge (Smaller width, white font, color-coded border for success/failure)
            Text(log.method)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 46, height: 20)
                .background(Color.black)
                .cornerRadius(5)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(statusColor, lineWidth: 1.2)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(log.url)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.95))
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                HStack(spacing: 8) {
                    // Status Code (Color-coded for immediate visual scanning)
                    Text("\(log.statusCode ?? 0)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(statusColor)
                    
                    Text("•")
                        .font(.system(size: 11))
                        .foregroundColor(Color.white.opacity(0.3))
                    
                    // Duration
                    Text(String(format: "%.2fs", log.duration))
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.5))
                    
                    if let size = log.responseSize {
                        Text("•")
                            .font(.system(size: 11))
                            .foregroundColor(Color.white.opacity(0.3))
                        Text(formatBytes(size))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.5))
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color.white.opacity(0.4))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(white: 0.08)) // Dark Charcoal Gray Card Background
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Custom Search Bar
struct CustomSearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.white.opacity(0.5))
            
            TextField("", text: $text, prompt: Text("Search endpoints...").foregroundColor(Color.white.opacity(0.45)))
                .foregroundColor(.white)
                .font(.system(size: 14, design: .rounded))
                .colorScheme(.dark)
            
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.white.opacity(0.5))
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(white: 0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 6)
    }
}

// MARK: - Scrolling Filter Section (Monochrome Pills)
struct HorizontalFilterSection: View {
    @Binding var selectedMethods: Set<String>
    @Binding var selectedStatus: Set<String>
    
    private let methods = ["GET", "POST", "PUT", "DELETE"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Method Pills
                ForEach(methods, id: \.self) { method in
                    let isSelected = selectedMethods.contains(method)
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            if isSelected {
                                selectedMethods.remove(method)
                            } else {
                                selectedMethods.insert(method)
                            }
                        }
                    }) {
                        Text(method)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundColor(isSelected ? .black : Color.white.opacity(0.6))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(isSelected ? Color.white : Color(white: 0.08))
                            .cornerRadius(100)
                            .overlay(
                                Capsule()
                                    .stroke(isSelected ? Color.white : Color.white.opacity(0.12), lineWidth: 1)
                            )
                    }
                }
                
                Divider()
                    .background(Color.white.opacity(0.15))
                    .frame(height: 18)
                    .padding(.horizontal, 2)
                
                // Status - Success (2xx)
                let isSuccessSelected = selectedStatus.contains("success")
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        if isSuccessSelected {
                            selectedStatus.remove("success")
                        } else {
                            selectedStatus.insert("success")
                        }
                    }
                }) {
                    Text("2xx OK")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(isSuccessSelected ? .black : Color.white.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isSuccessSelected ? Color.white : Color(white: 0.08))
                        .cornerRadius(100)
                        .overlay(
                            Capsule()
                                            .stroke(isSuccessSelected ? Color.white : Color.white.opacity(0.12), lineWidth: 1)
                        )
                }
                
                // Status - Failure (Error)
                let isFailureSelected = selectedStatus.contains("failure")
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        if isFailureSelected {
                            selectedStatus.remove("failure")
                        } else {
                            selectedStatus.insert("failure")
                        }
                    }
                }) {
                    Text("Errors")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(isFailureSelected ? .black : Color.white.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(isFailureSelected ? Color.white : Color(white: 0.08))
                        .cornerRadius(100)
                        .overlay(
                            Capsule()
                                .stroke(isFailureSelected ? Color.white : Color.white.opacity(0.12), lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal)
            .padding(.top, 6)
            .padding(.bottom, 12)
        }
    }
}
