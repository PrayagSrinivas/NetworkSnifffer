//
//  NetworkTraffic.swift
//  NetworkCall
//
//  Created by Srinivas Prayag Sahu on 26/12/25.
//


import Foundation

struct NetworkTraffic: Identifiable {
    let id = UUID()
    let timestamp: Date
    let url: String
    let method: String
    let statusCode: Int?
    let requestHeaders: [String: String]?
    let requestBody: String?
    let responseHeaders: [String: String]?
    let responseBody: String?
    let duration: TimeInterval
    
    // Enhanced timing data
    let timingData: TimingData?
    
    // Data sizes
    let requestSize: Int64?
    let responseSize: Int64?
    
    // Helper to format body data to String
    static func string(from data: Data?) -> String? {
        guard let data = data else { return nil }
        // Try pretty printing JSON
        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            return prettyString
        }
        // Fallback to plain string
        return String(data: data, encoding: .utf8)
    }
}

// Detailed timing breakdown similar to browser dev tools
struct TimingData {
    let dnsLookupDuration: TimeInterval?
    let connectDuration: TimeInterval?
    let secureConnectionDuration: TimeInterval?
    let requestDuration: TimeInterval?
    let responseDuration: TimeInterval?
    let totalDuration: TimeInterval
    
    // For display purposes
    var formattedDNS: String {
        guard let dns = dnsLookupDuration else { return "N/A" }
        return String(format: "%.3fs", dns)
    }
    
    var formattedConnect: String {
        guard let connect = connectDuration else { return "N/A" }
        return String(format: "%.3fs", connect)
    }
    
    var formattedSSL: String {
        guard let ssl = secureConnectionDuration else { return "N/A" }
        return String(format: "%.3fs", ssl)
    }
    
    var formattedWait: String {
        guard let wait = requestDuration else { return "N/A" }
        return String(format: "%.3fs", wait)
    }
    
    var formattedTransfer: String {
        guard let transfer = responseDuration else { return "N/A" }
        return String(format: "%.3fs", transfer)
    }
    
    var formattedTotal: String {
        String(format: "%.3fs", totalDuration)
    }
}
