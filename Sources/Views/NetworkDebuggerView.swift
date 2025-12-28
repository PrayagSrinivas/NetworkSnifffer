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
    
    // Filter logic
    var filteredLogs: [NetworkTraffic] {
        if searchText.isEmpty {
            return logger.logs
        } else {
            return logger.logs.filter { $0.url.localizedCaseInsensitiveContains(searchText) }
        }
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
            .navigationTitle("Network Traffic 🦊")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        // 1. Dismiss the SwiftUI Sheet
                        // Use the Environment dismiss if available, or this fallback:
                        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?
                            .rootViewController?.dismiss(animated: true, completion: nil)
                        
                        // 2. Tell Manager to shrink the window (It happens automatically in viewDidDisappear,
                        // but explicit calling is safe too)
                        DebuggerWindowManager.shared.minimizeWindow()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { logger.clearLogs() }) {
                        Image(systemName: "trash")
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
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
