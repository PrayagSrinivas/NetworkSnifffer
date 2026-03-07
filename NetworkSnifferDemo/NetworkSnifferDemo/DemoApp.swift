//
//  DemoApp.swift
//  NetworkSnifferDemo
//
//  A demo app to showcase NetworkSniffer library usage
//

import SwiftUI
import NetworkSnifffer

@main
struct DemoApp: App {
    
    init() {
        // Initialize the NetworkSniffer library
        // You can specify hosts to capture, or leave empty to capture all
        MyNetworkLib.start(capturedHosts: ["jsonplaceholder.typicode.com", "httpbin.org"])
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
