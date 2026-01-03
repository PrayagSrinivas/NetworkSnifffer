//
//  LogDetailView.swift
//  NetworkCall
//
//  Created by Srinivas Prayag Sahu on 26/12/25.
//


import SwiftUI

struct LogDetailView: View {
    let log: NetworkTraffic
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isShareSheetPresented = false
    
    var body: some View {
        ZStack {
            List {
                // --- GENERAL SECTION ---
                Section(
                    header: Text("General"),
                    footer: Text("Basic metadata about the request lifecycle.")
                ) {
                    InfoRow(label: "Method", value: log.method)
                    InfoRow(label: "Status", value: "\(log.statusCode ?? 0)")
                    InfoRow(label: "Duration", value: String(format: "%.3f s", log.duration))
                    InfoRow(label: "Time", value: log.timestamp.formatted(date: .omitted, time: .standard))
                    
                    // Interactive URL Row
                    HStack(alignment: .top) {
                        VStack(alignment: .leading) {
                            Text("URL").font(.caption).foregroundColor(.secondary)
                            Text(log.url).font(.subheadline)
                        }
                        Spacer()
                        Button(action: {
                            copyToClipboard(log.url)
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.borderless)
                    }
                    .padding(.vertical, 2)
                }
                
                // --- HEADERS SECTION ---
                if let headers = log.requestHeaders, !headers.isEmpty {
                    Section(header: Text("Request Headers")) {
                        ForEach(headers.sorted(by: >), id: \.key) { key, value in
                            InfoRow(label: key, value: value)
                        }
                    }
                }
                
                // --- REQUEST BODY ---
                if let body = log.requestBody, !body.isEmpty {
                    Section(
                        header: HStack {
                            Text("Request Body")
                            Spacer()
                            Button("Copy") { copyToClipboard(body) }
                                .font(.caption)
                        }
                    ) {
                        Text(body)
                            .font(.system(.caption, design: .monospaced))
                            .contextMenu { Button("Copy") { copyToClipboard(body) } }
                    }
                }
                
                // --- RESPONSE BODY ---
                if let body = log.responseBody {
                    Section(
                        header: HStack {
                            Text("Response Body")
                            Spacer()
                            Button("Copy") { copyToClipboard(body) }
                                .font(.caption)
                        }
                    ) {
                        Text(body)
                            .font(.system(.caption, design: .monospaced))
                            .contextMenu {
                                Button("Copy Response") { copyToClipboard(body) }
                            }
                    }
                }
            }
            .listStyle(.insetGrouped)
            
            // --- TOAST OVERLAY ---
            if showToast {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .font(.subheadline)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .zIndex(1) // Ensure it sits on top
            }
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isShareSheetPresented = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        // iOS 14 Compatible Share Sheet
        .sheet(isPresented: $isShareSheetPresented) {
            ShareSheet(activityItems: [generateShareText()])
        }
    }
    
    // Helper Functions
    func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        
        // Show Toast
        withAnimation {
            toastMessage = "Copied to clipboard ✅"
            showToast = true
        }
        
        // Hide Toast after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showToast = false
            }
        }
    }
    
    func generateShareText() -> String {
        return """
        Please check this network log:
        ---------------------------
        URL: \(log.url)
        Method: \(log.method)
        Status: \(log.statusCode ?? 0)
        
        Request Headers: \(log.requestHeaders ?? [:])
        
        Request Body:
        \(log.requestBody ?? "N/A")
        
        Response Body:
        \(log.responseBody ?? "N/A")
        ---------------------------
        """
    }
}

// Minimal Share Sheet Wrapper for iOS 14+
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// Reusable Row (Same as before)
struct InfoRow: View {
    let label: String
    let value: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(label).font(.caption).foregroundColor(.secondary)
            Text(value).font(.subheadline).textSelection(.enabled)
        }
        .padding(.vertical, 2)
    }
}
