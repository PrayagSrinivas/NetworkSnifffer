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
        ZStack {
            // Pitch Black Background
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Tab Bar Selector
                TabSelector(selectedTab: $selectedTab)
                
                // Tab Views
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
        }
        .navigationTitle("Network Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isShareSheetPresented = true }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $isShareSheetPresented) {
            ShareSheet(activityItems: [generateShareText()])
        }
        .overlay(toastOverlay)
        .colorScheme(.dark)
    }
    
    @ViewBuilder
    private var toastOverlay: some View {
        if showToast {
            VStack {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                    Text(toastMessage)
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.black)
                .overlay(
                    Capsule()
                        .stroke(Color.white, lineWidth: 1.5)
                )
                .cornerRadius(100)
                .shadow(color: Color.white.opacity(0.1), radius: 8, y: 4)
                .padding(.top, 16)
                .transition(.move(edge: .top).combined(with: .opacity))
                
                Spacer()
            }
            .zIndex(100)
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

// MARK: - Reusable Monochrome Card Section
struct GlassCardSection<Content: View>: View {
    let title: String
    var copyAction: (() -> Void)? = nil
    let content: Content
    
    init(title: String, copyAction: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.copyAction = copyAction
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.6)) // High-contrast gray title
                
                Spacer()
                
                if let copyAction = copyAction {
                    Button(action: copyAction) {
                        HStack(spacing: 4) {
                            Image(systemName: "doc.on.doc")
                            Text("Copy")
                        }
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 4)
            
            VStack(alignment: .leading, spacing: 12) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(Color(white: 0.08)) // Dark Charcoal Gray
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1) // High-readability border
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Tab Selector (Monochrome Sliding Capsule)
struct TabSelector: View {
    @Binding var selectedTab: Int
    private let tabs = ["Summary", "Request", "Response", "Timing"]
    @Namespace private var animationNamespace
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        selectedTab = index
                    }
                }) {
                    Text(tabs[index])
                        .font(.system(size: 13, weight: selectedTab == index ? .bold : .medium, design: .rounded))
                        .foregroundColor(selectedTab == index ? .black : Color.white.opacity(0.6)) // High contrast unselected titles
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            ZStack {
                                if selectedTab == index {
                                    Capsule()
                                        .fill(Color.white) // Solid White active capsule
                                        .matchedGeometryEffect(id: "activeTab", in: animationNamespace)
                                }
                            }
                        )
                }
            }
        }
        .padding(4)
        .background(Color(white: 0.08))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - Summary Tab
struct SummaryTabView: View {
    let log: NetworkTraffic
    @Binding var showToast: Bool
    @Binding var toastMessage: String
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Timing Breakdown
                if let timing = log.timingData {
                    GlassCardSection(title: "Timing Breakdown") {
                        TimingChart(timing: timing)
                    }
                }
                
                // Overview Section
                GlassCardSection(title: "Overview") {
                    InfoRow(label: "Method", value: log.method)
                        .contextMenu {
                            Button("Copy") { copyToClipboard(log.method) }
                        }
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    InfoRow(label: "Full URL", value: log.url)
                        .contextMenu {
                            Button("Copy") { copyToClipboard(log.url) }
                        }
                    
                    if let statusCode = log.statusCode {
                        Divider().background(Color.white.opacity(0.1))
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
                        Divider().background(Color.white.opacity(0.1))
                        InfoRow(label: "Data Sent", value: formatBytes(reqSize))
                    }
                    
                    if let resSize = log.responseSize {
                        Divider().background(Color.white.opacity(0.1))
                        InfoRow(label: "Data Received", value: formatBytes(resSize))
                    }
                    
                    Divider().background(Color.white.opacity(0.1))
                    InfoRow(label: "Time", value: log.timestamp.formatted(date: .abbreviated, time: .standard))
                }
                
                // Server Info
                if let headers = log.responseHeaders {
                    GlassCardSection(title: "Server Info") {
                        let server = headers["Server"] ?? headers["server"]
                        let contentType = headers["Content-Type"] ?? headers["content-type"]
                        let contentLength = headers["Content-Length"] ?? headers["content-length"]
                        
                        if let s = server {
                            InfoRow(label: "Server", value: s)
                            if contentType != nil || contentLength != nil { Divider().background(Color.white.opacity(0.1)) }
                        }
                        if let cType = contentType {
                            InfoRow(label: "Content-Type", value: cType)
                            if contentLength != nil { Divider().background(Color.white.opacity(0.1)) }
                        }
                        if let cLen = contentLength {
                            InfoRow(label: "Content-Length", value: cLen)
                        }
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            toastMessage = "Copied to clipboard"
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
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
        ScrollView {
            VStack(spacing: 8) {
                // Request Headers
                if let headers = log.requestHeaders, !headers.isEmpty {
                    GlassCardSection(title: "Request Headers", copyAction: {
                        copyToClipboard(formatHeaders(headers))
                    }) {
                        ForEach(headers.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(key)
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.6))
                                Text(value)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.white)
                                    .textSelection(.enabled)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                
                // Request Body
                if let body = log.requestBody, !isBodyEmpty(body) {
                    GlassCardSection(title: "Request Body", copyAction: {
                        copyToClipboard(body)
                    }) {
                        Text(JSONHighlighter.highlight(body))
                            .textSelection(.enabled)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.up.doc.dash")
                            .font(.system(size: 40))
                            .foregroundColor(Color.white.opacity(0.35))
                        
                        VStack(spacing: 6) {
                            Text("No Request Body")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("This HTTP request did not send any body data payload.")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.55))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 48)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 80)
                }
            }
            .padding(.bottom, 24)
        }
    }
    
    private func formatHeaders(_ headers: [String: String]) -> String {
        headers.sorted(by: { $0.key < $1.key })
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            toastMessage = "Copied to clipboard"
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
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
        ScrollView {
            VStack(spacing: 8) {
                // Response Headers
                if let headers = log.responseHeaders, !headers.isEmpty {
                    GlassCardSection(title: "Response Headers", copyAction: {
                        copyToClipboard(formatHeaders(headers))
                    }) {
                        ForEach(headers.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            VStack(alignment: .leading, spacing: 2) {
                                Text(key)
                                    .font(.system(.caption2, design: .rounded))
                                    .foregroundColor(Color.white.opacity(0.6))
                                Text(value)
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.white)
                                    .textSelection(.enabled)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                
                // Response Body
                if let body = log.responseBody, !isBodyEmpty(body) {
                    GlassCardSection(title: "Response Body", copyAction: {
                        copyToClipboard(body)
                    }) {
                        Text(JSONHighlighter.highlight(body))
                            .textSelection(.enabled)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "arrow.down.doc.dash")
                            .font(.system(size: 40))
                            .foregroundColor(Color.white.opacity(0.35))
                        
                        VStack(spacing: 6) {
                            Text("No Response Body")
                                .font(.system(.subheadline, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("The server did not return a body data payload for this request.")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Color.white.opacity(0.55))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 48)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 80)
                }
            }
            .padding(.bottom, 24)
        }
    }
    
    private func formatHeaders(_ headers: [String: String]) -> String {
        headers.sorted(by: { $0.key < $1.key })
            .map { "\($0.key): \($0.value)" }
            .joined(separator: "\n")
    }
    
    private func copyToClipboard(_ text: String) {
        UIPasteboard.general.string = text
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            toastMessage = "Copied to clipboard"
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { showToast = false }
        }
    }
}

// MARK: - Timing Tab
struct TimingTabView: View {
    let log: NetworkTraffic
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                if let timing = log.timingData {
                    GlassCardSection(title: "Timing Breakdown") {
                        TimingChart(timing: timing)
                    }
                    
                    GlassCardSection(title: "Details") {
                        if let dns = timing.dnsLookupDuration {
                            TimingRow(label: "DNS Lookup", duration: dns, color: Color(white: 0.2))
                            Divider().background(Color.white.opacity(0.1))
                        }
                        
                        if let connect = timing.connectDuration {
                            TimingRow(label: "Connect", duration: connect, color: Color(white: 0.4))
                            Divider().background(Color.white.opacity(0.1))
                        }
                        
                        if let ssl = timing.secureConnectionDuration {
                            TimingRow(label: "SSL/TLS", duration: ssl, color: Color(white: 0.6))
                            Divider().background(Color.white.opacity(0.1))
                        }
                        
                        if let wait = timing.requestDuration {
                            TimingRow(label: "Wait (TTFB)", duration: wait, color: Color(white: 0.8))
                            Divider().background(Color.white.opacity(0.1))
                        }
                        
                        if let transfer = timing.responseDuration {
                            TimingRow(label: "Content Download", duration: transfer, color: Color.white)
                            Divider().background(Color.white.opacity(0.1))
                        }
                        
                        HStack {
                            Text("Total")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(.white)
                            Spacer()
                            Text(String(format: "%.3fs", timing.totalDuration))
                                .font(.system(.headline, design: .monospaced))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    GlassCardSection(title: "Information") {
                        VStack(alignment: .leading, spacing: 8) {
                            TimingInfoLabel(title: "DNS Lookup", desc: "Domain name resolution time", icon: "server.rack")
                            TimingInfoLabel(title: "Connect", desc: "TCP connection handshake duration", icon: "network")
                            TimingInfoLabel(title: "SSL/TLS", desc: "Secure connection handshake time", icon: "lock.shield")
                            TimingInfoLabel(title: "Wait (TTFB)", desc: "Time to first byte received from server", icon: "hourglass")
                            TimingInfoLabel(title: "Content Download", desc: "Data transfer completion time", icon: "arrow.down.circle")
                        }
                        .padding(.vertical, 2)
                    }
                } else {
                    GlassCardSection(title: "Timing") {
                        Text("No detailed timing data available")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Color.white.opacity(0.5))
                            .italic()
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }
}

// MARK: - Supporting Detail Views
struct TimingRow: View {
    let label: String
    let duration: TimeInterval
    let color: Color
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(label)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            Spacer()
            Text(String(format: "%.3fs", duration))
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(Color.white.opacity(0.6))
        }
        .padding(.vertical, 2)
    }
}

struct TimingChart: View {
    let timing: TimingData
    @State private var isAnimate = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Visual waterfall bars
            VStack(spacing: 8) {
                if let dns = timing.dnsLookupDuration {
                    TimingBar(label: "DNS", duration: dns, total: timing.totalDuration, color: Color(white: 0.2), animate: isAnimate)
                }
                
                if let connect = timing.connectDuration {
                    TimingBar(label: "Connect", duration: connect, total: timing.totalDuration, color: Color(white: 0.4), animate: isAnimate)
                }
                
                if let ssl = timing.secureConnectionDuration {
                    TimingBar(label: "SSL", duration: ssl, total: timing.totalDuration, color: Color(white: 0.6), animate: isAnimate)
                }
                
                if let wait = timing.requestDuration {
                    TimingBar(label: "Wait", duration: wait, total: timing.totalDuration, color: Color(white: 0.8), animate: isAnimate)
                }
                
                if let transfer = timing.responseDuration {
                    TimingBar(label: "Transfer", duration: transfer, total: timing.totalDuration, color: Color.white, animate: isAnimate)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                    isAnimate = true
                }
            }
            
            Divider().background(Color.white.opacity(0.1))
            
            // Total time
            HStack {
                Text("Total Latency:")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Spacer()
                Text(String(format: "%.3fs", timing.totalDuration))
                    .font(.system(.subheadline, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding(.top, 2)
        }
        .padding(.vertical, 4)
    }
}

struct TimingBar: View {
    let label: String
    let duration: TimeInterval
    let total: TimeInterval
    let color: Color
    let animate: Bool
    
    private var percentage: CGFloat {
        CGFloat(min(duration / total, 1.0))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.6))
                    .frame(width: 60, alignment: .leading)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color)
                            .frame(width: max(geometry.size.width * percentage * (animate ? 1.0 : 0.0), 2), height: 12)
                    }
                }
                .frame(height: 12)
                
                Text(String(format: "%.3fs", duration))
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(Color.white.opacity(0.6))
                    .frame(width: 50, alignment: .trailing)
            }
        }
    }
}

struct TimingInfoLabel: View {
    let title: String
    let desc: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(.white)
                .frame(width: 18)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(Color.white.opacity(0.6))
            }
        }
        .padding(.vertical, 1)
    }
}

struct StatusBadge: View {
    let statusCode: Int
    
    private var isSuccess: Bool {
        statusCode >= 200 && statusCode < 300
    }
    
    private var statusText: String {
        switch statusCode {
        case 200: return "OK"
        case 201: return "Created"
        case 204: return "No Content"
        case 301: return "Moved"
        case 302: return "Found"
        case 304: return "Unchanged"
        case 400: return "Bad Request"
        case 401: return "Unauthorized"
        case 403: return "Forbidden"
        case 404: return "Not Found"
        case 500: return "Server Error"
        case 502: return "Bad Gateway"
        case 503: return "Unavailable"
        default: return "HTTP \(statusCode)"
        }
    }
    
    var body: some View {
        Text(statusText)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundColor(isSuccess ? .black : .white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSuccess ? Color.white : Color.black)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white, lineWidth: isSuccess ? 0 : 1)
            )
            .shadow(color: Color.white.opacity(0.05), radius: 3)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(Color.white.opacity(0.6))
            Text(value)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.white)
                .textSelection(.enabled)
        }
        .padding(.vertical, 1)
    }
}

// MARK: - Share Sheet (UIKit bridge)
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

fileprivate func isBodyEmpty(_ body: String?) -> Bool {
    guard let body = body else { return true }
    let cleaned = body.components(separatedBy: .whitespacesAndNewlines).joined()
    return cleaned.isEmpty || cleaned == "{}" || cleaned == "[]"
}
