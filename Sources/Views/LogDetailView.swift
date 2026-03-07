//
//  LogDetailView.swift
//  NetworkCall
//
//  Created by Srinivas Prayag Sahu on 26/12/25.
//


import SwiftUI

struct LogDetailView: View {
    let log: NetworkTraffic
    @State private var selectedTab = 0
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var isShareSheetPresented = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            TabSelector(selectedTab: $selectedTab)
            
            // Tab Content
            TabView(selection: $selectedTab) {
                SummaryTabView(log: log, showToast: $showToast, toastMessage: $toastMessage)
                    .tag(0)
                
                RequestTabView(log: log, showToast: $showToast, toastMessage: $toastMessage)
                    .tag(1)
                
                ResponseTabView(log: log, showToast: $showToast, toastMessage: $toastMessage)
                    .tag(2)
                
                TimingTabView(log: log)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Network Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isShareSheetPresented = true }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ShareSheet(activityItems: [generateShareText()])
        }
        .overlay(toastOverlay)
    }
    
    @ViewBuilder
    private var toastOverlay: some View {
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
            .zIndex(1)
        }
    }
    
    func generateShareText() -> String {
        return """
        Network Log Details
        ---------------------------
        URL: \(log.url)
        Method: \(log.method)
        Status: \(log.statusCode ?? 0)
        Duration: \(String(format: "%.3fs", log.duration))
        Time: \(log.timestamp.formatted())
        
        Request Headers:
        \(log.requestHeaders?.map { "\($0.key): \($0.value)" }.joined(separator: "\n") ?? "None")
        
        Request Body:
        \(log.requestBody ?? "None")
        
        Response Body:
        \(log.responseBody ?? "None")
        ---------------------------
        """
    }
}

// MARK: - Tab Selector
struct TabSelector: View {
    @Binding var selectedTab: Int
    
    private let tabs = ["Summary", "Request", "Response", "Timing"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Text(tabs[index])
                            .font(.subheadline)
                            .fontWeight(selectedTab == index ? .semibold : .regular)
                            .foregroundColor(selectedTab == index ? .blue : .secondary)
                        
                        Rectangle()
                            .fill(selectedTab == index ? Color.blue : Color.clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Summary Tab
struct SummaryTabView: View {
    let log: NetworkTraffic
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    var body: some View {
        List {
            // Visual Timing Chart
            if let timing = log.timingData {
                Section(header: Text("Timing Breakdown")) {
                    TimingChart(timing: timing)
                }
            }
            
            // Overview Section
            Section(header: Text("Overview")) {
                InfoRow(label: "Method", value: log.method)
                    .contextMenu {
                        Button("Copy") { copyToClipboard(log.method) }
                    }
                
                InfoRow(label: "Full URL", value: log.url)
                    .contextMenu {
                        Button("Copy") { copyToClipboard(log.url) }
                    }
                
                if let statusCode = log.statusCode {
                    HStack {
                        InfoRow(label: "Status Code", value: "\(statusCode)")
                        Spacer()
                        StatusBadge(statusCode: statusCode)
                    }
                    .contextMenu {
                        Button("Copy") { copyToClipboard("\(statusCode)") }
                    }
                }
                
                if let reqSize = log.requestSize {
                    InfoRow(label: "Data sent", value: formatBytes(reqSize))
                }
                
                if let resSize = log.responseSize {
                    InfoRow(label: "Data received", value: formatBytes(resSize))
                }
                
                InfoRow(label: "Time", value: log.timestamp.formatted(date: .abbreviated, time: .standard))
            }
            
            // Server Info
            if let headers = log.responseHeaders {
                Section(header: Text("Server Info")) {
                    if let server = headers["Server"] {
                        InfoRow(label: "Server", value: server)
                    }
                    if let contentType = headers["Content-Type"] {
                        InfoRow(label: "Content-Type", value: contentType)
                    }
                    if let contentLength = headers["Content-Length"] {
                        InfoRow(label: "Content-Length", value: contentLength)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        withAnimation {
            toastMessage = "Copied ✅"
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showToast = false }
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Request Tab
struct RequestTabView: View {
    let log: NetworkTraffic
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    var body: some View {
        List {
            // Request Headers
            if let headers = log.requestHeaders, !headers.isEmpty {
                Section(header: sectionHeader(title: "Request Headers", copyAction: {
                    copyToClipboard(formatHeaders(headers))
                })) {
                    ForEach(headers.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(key)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(value)
                                .font(.subheadline)
                                .textSelection(.enabled)
                        }
                        .padding(.vertical, 4)
                        .contextMenu {
                            Button("Copy Key") { copyToClipboard(key) }
                            Button("Copy Value") { copyToClipboard(value) }
                            Button("Copy Both") { copyToClipboard("\(key): \(value)") }
                        }
                    }
                }
            }
            
            // Request Body
            if let body = log.requestBody, !body.isEmpty {
                Section(header: sectionHeader(title: "Request Body", copyAction: {
                    copyToClipboard(body)
                })) {
                    Text(body)
                        .font(.system(.caption, design: .monospaced))
                        .textSelection(.enabled)
                        .padding(.vertical, 4)
                }
            } else {
                Section(header: Text("Request Body")) {
                    Text("No request body")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func sectionHeader(title: String, copyAction: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
            Spacer()
            Button(action: copyAction) {
                HStack(spacing: 4) {
                    Image(systemName: "doc.on.doc")
                    Text("Copy")
                }
                .font(.caption)
            }
        }
    }
    
    private func formatHeaders(_ headers: [String: String]) -> String {
        headers.sorted(by: { $0.key < $1.key })
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        withAnimation {
            toastMessage = "Copied ✅"
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showToast = false }
        }
    }
}

// MARK: - Response Tab
struct ResponseTabView: View {
    let log: NetworkTraffic
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    var body: some View {
        List {
            // Response Headers
            if let headers = log.responseHeaders, !headers.isEmpty {
                Section(header: sectionHeader(title: "Response Headers", copyAction: {
                    copyToClipboard(formatHeaders(headers))
                })) {
                    ForEach(headers.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(key)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(value)
                                .font(.subheadline)
                                .textSelection(.enabled)
                        }
                        .padding(.vertical, 4)
                        .contextMenu {
                            Button("Copy Key") { copyToClipboard(key) }
                            Button("Copy Value") { copyToClipboard(value) }
                            Button("Copy Both") { copyToClipboard("\(key): \(value)") }
                        }
                    }
                }
            }
            
            // Response Body
            if let body = log.responseBody, !body.isEmpty {
                Section(header: sectionHeader(title: "Response Body", copyAction: {
                    copyToClipboard(body)
                })) {
                    ScrollView {
                        Text(body)
                            .font(.system(.caption, design: .monospaced))
                            .textSelection(.enabled)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 4)
                    }
                    .frame(maxHeight: 400)
                }
            } else {
                Section(header: Text("Response Body")) {
                    Text("No response body")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    private func sectionHeader(title: String, copyAction: @escaping () -> Void) -> some View {
        HStack {
            Text(title)
            Spacer()
            Button(action: copyAction) {
                HStack(spacing: 4) {
                    Image(systemName: "doc.on.doc")
                    Text("Copy")
                }
                .font(.caption)
            }
        }
    }
    
    private func formatHeaders(_ headers: [String: String]) -> String {
        headers.sorted(by: { $0.key < $1.key })
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        withAnimation {
            toastMessage = "Copied ✅"
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showToast = false }
        }
    }
}

// MARK: - Timing Tab
struct TimingTabView: View {
    let log: NetworkTraffic
    
    var body: some View {
        List {
            if let timing = log.timingData {
                Section(header: Text("Timing Breakdown")) {
                    TimingChart(timing: timing)
                }
                
                Section(header: Text("Details")) {
                    if let dns = timing.dnsLookupDuration {
                        TimingRow(label: "DNS Lookup", duration: dns, color: .gray)
                    }
                    
                    if let connect = timing.connectDuration {
                        TimingRow(label: "Connect", duration: connect, color: .purple)
                    }
                    
                    if let ssl = timing.secureConnectionDuration {
                        TimingRow(label: "SSL/TLS", duration: ssl, color: .green)
                    }
                    
                    if let wait = timing.requestDuration {
                        TimingRow(label: "Wait (TTFB)", duration: wait, color: .orange)
                    }
                    
                    if let transfer = timing.responseDuration {
                        TimingRow(label: "Content Download", duration: transfer, color: .blue)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.3fs", timing.totalDuration))
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Information")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("DNS Lookup: Time to resolve domain name", systemImage: "server.rack")
                        Label("Connect: Time to establish TCP connection", systemImage: "network")
                        Label("SSL/TLS: Time for secure handshake", systemImage: "lock.shield")
                        Label("Wait (TTFB): Time to first byte from server", systemImage: "hourglass")
                        Label("Content Download: Time to receive response", systemImage: "arrow.down.circle")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 4)
                }
            } else {
                Section {
                    Text("No detailed timing data available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Supporting Views

struct TimingRow: View {
    let label: String
    let duration: TimeInterval
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                Text(label)
                    .font(.subheadline)
            }
            Spacer()
            Text(String(format: "%.3fs", duration))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct TimingChart: View {
    let timing: TimingData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Visual waterfall chart
            VStack(spacing: 6) {
                if let dns = timing.dnsLookupDuration {
                    TimingBar(label: "DNS", duration: dns, total: timing.totalDuration, color: .gray)
                }
                
                if let connect = timing.connectDuration {
                    TimingBar(label: "Connect", duration: connect, total: timing.totalDuration, color: .purple)
                }
                
                if let ssl = timing.secureConnectionDuration {
                    TimingBar(label: "SSL", duration: ssl, total: timing.totalDuration, color: .green)
                }
                
                if let wait = timing.requestDuration {
                    TimingBar(label: "Wait", duration: wait, total: timing.totalDuration, color: .orange)
                }
                
                if let transfer = timing.responseDuration {
                    TimingBar(label: "Transfer", duration: transfer, total: timing.totalDuration, color: .blue)
                }
            }
            
            // Total time
            HStack {
                Text("Total Time:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "%.3fs", timing.totalDuration))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }
}

struct TimingBar: View {
    let label: String
    let duration: TimeInterval
    let total: TimeInterval
    let color: Color
    
    private var percentage: CGFloat {
        CGFloat(min(duration / total, 1.0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 60, alignment: .leading)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color.gray.opacity(0.1))
                            .frame(height: 20)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(color)
                            .frame(width: max(geometry.size.width * percentage, 2), height: 20)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 20)
                
                Text(String(format: "%.3fs", duration))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .trailing)
            }
        }
    }
}

struct StatusBadge: View {
    let statusCode: Int
    
    private var badgeColor: Color {
        switch statusCode {
        case 200..<300: return .green
        case 300..<400: return .orange
        case 400..<500: return .red
        case 500..<600: return .purple
        default: return .gray
        }
    }
    
    private var statusText: String {
        switch statusCode {
        case 200: return "OK"
        case 201: return "Created"
        case 204: return "No Content"
        case 301: return "Moved Permanently"
        case 302: return "Found"
        case 304: return "Not Modified"
        case 400: return "Bad Request"
        case 401: return "Unauthorized"
        case 403: return "Forbidden"
        case 404: return "Not Found"
        case 500: return "Server Error"
        case 502: return "Bad Gateway"
        case 503: return "Service Unavailable"
        default: return ""
        }
    }
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(badgeColor)
            .cornerRadius(6)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .textSelection(.enabled)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
