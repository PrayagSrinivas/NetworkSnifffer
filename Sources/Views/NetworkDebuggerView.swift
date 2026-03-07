//
//  NetworkDebuggerView.swift
//  NetworkCall
//
//  Created by Srinivas Prayag Sahu on 26/12/25.
//


// NetworkDebuggerView.swift (formerly ContentView)
import SwiftUI

public struct NetworkDebuggerView: View {
    @ObservedObject var logger = NetworkLogger.shared
    @State private var searchText = ""
    @State private var selectedMethods: Set<String> = []
    @State private var selectedStatus: Set<String> = [] // "success" or "failure"
    
    // Available methods in current logs
    var availableMethods: [String] {
        let methods = Set(logger.logs.map { $0.method })
        return ["GET", "POST", "PUT", "DELETE"].filter { methods.contains($0) }
    }
    
    // Check if there are success and failure responses
    var hasSuccessResponses: Bool {
        logger.logs.contains { log in
            if let code = log.statusCode {
                return code >= 200 && code < 400
            }
            return false
        }
    }
    
    var hasFailureResponses: Bool {
        logger.logs.contains { log in
            if let code = log.statusCode {
                return code >= 400
            }
            return false
        }
    }
    
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
    
    // Check if any filters are active
    var hasActiveFilters: Bool {
        !selectedMethods.isEmpty || !selectedStatus.isEmpty
    }
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List(filteredLogs) { log in
                NavigationLink(destination: LogDetailView(log: log)) {
                    HStack {
                        // Method Badge
                        Text(log.method)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(6)
                            .background(methodColor(log.method))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(log.url)
                                .font(.caption)
                                .lineLimit(1)
                                .truncationMode(.middle) // Shows start and end of long URLs
                            
                            HStack {
                                Text("\(log.statusCode ?? 0)")
                                    .foregroundColor(statusColor(log.statusCode))
                                    .fontWeight(.medium)
                                Text("•")
                                Text(String(format: "%.2fs", log.duration))
                            }
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .listStyle(.insetGrouped) // A slightly cleaner look
            .searchable(text: $searchText, prompt: "Search endpoints...") // Built-in Search
            .navigationTitle("Network Traffic")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        // JUST dismiss. Don't call minimizeWindow() manually!
                        // This lets the animation finish smoothly.
                        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?
                            .rootViewController?.dismiss(animated: true, completion: nil)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        // Filter Menu Button
                        Menu {
                            // Status Filter Section
                            if hasSuccessResponses || hasFailureResponses {
                                Section(header: Text("Status")) {
                                    if hasSuccessResponses {
                                        Button(action: { toggleStatusFilter("success") }) {
                                            Label(
                                                selectedStatus.contains("success") ? "✓ Success (2xx-3xx)" : "Success (2xx-3xx)",
                                                systemImage: selectedStatus.contains("success") ? "checkmark.circle.fill" : "circle"
                                            )
                                        }
                                    }
                                    
                                    if hasFailureResponses {
                                        Button(action: { toggleStatusFilter("failure") }) {
                                            Label(
                                                selectedStatus.contains("failure") ? "✓ Failure (4xx-5xx)" : "Failure (4xx-5xx)",
                                                systemImage: selectedStatus.contains("failure") ? "checkmark.circle.fill" : "circle"
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // Methods Filter Section
                            if !availableMethods.isEmpty {
                                Section(header: Text("Methods")) {
                                    ForEach(availableMethods, id: \.self) { method in
                                        Button(action: { toggleMethodFilter(method) }) {
                                            Label(
                                                selectedMethods.contains(method) ? "✓ \(method)" : method,
                                                systemImage: selectedMethods.contains(method) ? "checkmark.circle.fill" : "circle"
                                            )
                                        }
                                    }
                                }
                            }
                            
                            // Clear Filters Option
                            if hasActiveFilters {
                                Section {
                                    Button(role: .destructive, action: clearFilters) {
                                        Label("Clear All Filters", systemImage: "xmark.circle")
                                    }
                                }
                            }
                            
                            // Empty state
                            if availableMethods.isEmpty && !hasSuccessResponses && !hasFailureResponses {
                                Text("No data to filter")
                                    .foregroundColor(.secondary)
                            }
                        } label: {
                            ZStack {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                
                                // Badge indicator when filters are active
                                if hasActiveFilters {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 8, height: 8)
                                        .offset(x: 10, y: -10)
                                }
                            }
                        }
                        .disabled(logger.logs.isEmpty)
                        
                        // Delete Button
                        Button(action: {
                            logger.clearLogs()
                            clearFilters()
                            UIApplication.shared.windows.first(where: { $0.isKeyWindow })?
                                .rootViewController?.dismiss(animated: true, completion: nil)
                        }) {
                            Image(systemName: "trash")
                        }
                        .disabled(logger.logs.isEmpty)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    // --- Helper Functions ---
    
    func toggleMethodFilter(_ method: String) {
        if selectedMethods.contains(method) {
            selectedMethods.remove(method)
        } else {
            selectedMethods.insert(method)
        }
    }
    
    func toggleStatusFilter(_ status: String) {
        if selectedStatus.contains(status) {
            selectedStatus.remove(status)
        } else {
            selectedStatus.insert(status)
        }
    }
    
    func clearFilters() {
        selectedMethods.removeAll()
        selectedStatus.removeAll()
    }
    
    // --- Helper Colors ---
    func methodColor(_ method: String) -> Color {
        switch method {
        case "GET": return .blue
        case "POST": return .orange
        case "DELETE": return .red
        case "PUT": return .purple
        default: return .gray
        }
    }
    
    func statusColor(_ code: Int?) -> Color {
        guard let code = code else { return .gray }
        if code >= 200 && code < 300 { return .green }
        if code >= 400 && code < 500 { return .orange }
        return .red
    }
}
