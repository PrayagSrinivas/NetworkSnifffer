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