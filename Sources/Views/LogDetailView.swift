//
//  LogDetailView.swift
//  NetworkCall
//
//  Created by Srinivas Prayag Sahu on 26/12/25.
//


import SwiftUI

struct LogDetailView: View {
    let log: NetworkTraffic
    @State private var isCopied = false
    
    var body: some View {
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
                        UIPasteboard.general.string = log.url
                        // Simple feedback animation
                        withAnimation { isCopied = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { isCopied = false }
                    }) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .foregroundColor(isCopied ? .green : .blue)
                    }
                    .buttonStyle(.borderless) // Important for buttons inside Lists
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
                        Button("Copy") { UIPasteboard.general.string = body }
                            .font(.caption)
                    },
                    footer: Text("Payload sent to the server.")
                ) {
                    Text(body)
                        .font(.system(.caption, design: .monospaced))
                        .contextMenu { Button("Copy") { UIPasteboard.general.string = body } }
                }
            }
            
            // --- RESPONSE BODY ---
            if let body = log.responseBody {
                Section(
                    header: HStack {
                        Text("Response Body")
                        Spacer()
                        Button("Copy") { UIPasteboard.general.string = body }
                            .font(.caption)
                    },
                    footer: Text("Raw data returned by the server. JSON is pretty-printed automatically.")
                ) {
                    Text(body)
                        .font(.system(.caption, design: .monospaced))
                        .contextMenu {
                            Button("Copy Response") { UIPasteboard.general.string = body }
                        }
                }
            }
        }
        .navigationTitle("Details")
    }
}

// Reusable Row Component
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                // Allow long text to select/copy
                .textSelection(.enabled)
        }
        .padding(.vertical, 2)
    }
}
