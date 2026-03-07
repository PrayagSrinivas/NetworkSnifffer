//
//  NetworkDemoViewModel.swift
//  NetworkSnifferDemo
//
//  ViewModel to handle API calls for demo purposes
//

import Foundation
import SwiftUI
import Combine

@MainActor
class NetworkDemoViewModel: ObservableObject {
    @Published var isLoadingGet = false
    @Published var isLoadingPost = false
    @Published var isLoadingPut = false
    @Published var isLoadingDelete = false
    @Published var lastResponse: String?
    
    private let apiService = APIService()
    
    // GET Request Test
    func testGetRequest() async {
        isLoadingGet = true
        defer { isLoadingGet = false }
        
        do {
            let result = try await apiService.getRequest()
            lastResponse = "GET Success: \(result.prefix(100))..."
        } catch {
            lastResponse = "GET Error: \(error.localizedDescription)"
        }
    }
    
    // POST Request Test
    func testPostRequest() async {
        isLoadingPost = true
        defer { isLoadingPost = false }
        
        do {
            let result = try await apiService.postRequest()
            lastResponse = "POST Success: \(result.prefix(100))..."
        } catch {
            lastResponse = "POST Error: \(error.localizedDescription)"
        }
    }
    
    // PUT Request Test
    func testPutRequest() async {
        isLoadingPut = true
        defer { isLoadingPut = false }
        
        do {
            let result = try await apiService.putRequest()
            lastResponse = "PUT Success: \(result.prefix(100))..."
        } catch {
            lastResponse = "PUT Error: \(error.localizedDescription)"
        }
    }
    
    // DELETE Request Test
    func testDeleteRequest() async {
        isLoadingDelete = true
        defer { isLoadingDelete = false }
        
        do {
            let result = try await apiService.deleteRequest()
            lastResponse = "DELETE Success: \(result)"
        } catch {
            lastResponse = "DELETE Error: \(error.localizedDescription)"
        }
    }
}
