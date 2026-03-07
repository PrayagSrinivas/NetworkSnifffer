//
//  APIService.swift
//  NetworkSnifferDemo
//
//  Service class to handle different types of HTTP requests
//

import Foundation

class APIService {
    
    // Base URLs for testing
    private let jsonPlaceholderURL = "https://jsonplaceholder.typicode.com"
    private let httpBinURL = "https://httpbin.org"
    
    // MARK: - GET Request
    func getRequest() async throws -> String {
        let url = URL(string: "\(jsonPlaceholderURL)/posts/1")!
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        throw APIError.invalidData
    }
    
    // MARK: - POST Request
    func postRequest() async throws -> String {
        let url = URL(string: "\(jsonPlaceholderURL)/posts")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let postData: [String: Any] = [
            "title": "Demo Post from NetworkSniffer",
            "body": "This is a test POST request",
            "userId": 1
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: postData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        throw APIError.invalidData
    }
    
    // MARK: - PUT Request
    func putRequest() async throws -> String {
        let url = URL(string: "\(jsonPlaceholderURL)/posts/1")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let putData: [String: Any] = [
            "id": 1,
            "title": "Updated Post Title",
            "body": "This is an updated body from NetworkSniffer demo",
            "userId": 1
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: putData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        if let jsonString = String(data: data, encoding: .utf8) {
            return jsonString
        }
        throw APIError.invalidData
    }
    
    // MARK: - DELETE Request
    func deleteRequest() async throws -> String {
        let url = URL(string: "\(jsonPlaceholderURL)/posts/1")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        return "Resource deleted successfully (Status: \(httpResponse.statusCode))"
    }
}

// MARK: - Error Types
enum APIError: LocalizedError {
    case invalidResponse
    case invalidData
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidData:
            return "Could not parse response data"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
