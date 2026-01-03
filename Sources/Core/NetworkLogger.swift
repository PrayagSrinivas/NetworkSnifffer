import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

// MARK: - 1. The Storage Manager (Singleton)
@MainActor
public class NetworkLogger: ObservableObject {
    public static let shared = NetworkLogger()
    
    // Holds all the captured network traffic
    @Published var logs: [NetworkTraffic] = []
    
    // Controls the visibility of the full-screen debugger sheet
    @Published public var isDashboardPresented = false
    
    private var cancellables = Set<AnyCancellable>()
    
    // Thread-safe queue for processing logs
    private let queue = DispatchQueue(label: "com.mynetworklib.storage", attributes: .concurrent)
    
    private init() {
        // Listen for the Shake Notification (broadcasted by the UIWindow extension below)
        NotificationCenter.default.publisher(for: .deviceDidShake)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                // Toggle the dashboard view
                self?.isDashboardPresented.toggle()
            }
            .store(in: &cancellables)
    }
    
    /// Main function to capture and process a network request
    func log(request: URLRequest, response: URLResponse?, responseData: Data?, error: Error?, startTime: Date) {
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        
        // 1. Parse Request Details
        let url = request.url?.absoluteString ?? "Unknown URL"
        let method = request.httpMethod ?? "GET"
        let reqHeaders = request.allHTTPHeaderFields
        let reqBody = NetworkTraffic.string(from: request.httpBody)
        
        // 2. Parse Response Details
        var statusCode: Int?
        var resHeaders: [String: String]?
        
        if let httpResponse = response as? HTTPURLResponse {
            statusCode = httpResponse.statusCode
            resHeaders = httpResponse.allHeaderFields as? [String: String]
        }
        
        let resBody = NetworkTraffic.string(from: responseData)
        
        // 3. Create the Model
        let traffic = NetworkTraffic(
            timestamp: startTime,
            url: url,
            method: method,
            statusCode: statusCode,
            requestHeaders: reqHeaders,
            requestBody: reqBody,
            responseHeaders: resHeaders,
            responseBody: resBody,
            duration: duration
        )
        
        // 4. Update the UI (Must be on Main Thread)
        DispatchQueue.main.async {
            // Insert at the top (newest first)
            self.logs.insert(traffic, at: 0)
        }
    }
    
    func clearLogs() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
    }
}

extension NSNotification.Name {
    static let deviceDidShake = NSNotification.Name("deviceDidShake")
}

// Override the default window behavior to detect shakes globally
extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            // Post a notification when a shake happens
            NotificationCenter.default.post(name: .deviceDidShake, object: nil)
        }
        super.motionEnded(motion, with: event)
    }
}
