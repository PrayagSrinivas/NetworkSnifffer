//
//  MyNetworkLib.swift
//  NetworkCall
//
//  Created by Srinivas Prayag Sahu on 26/12/25.
//


import Foundation

public class MyNetworkLib {
    
    // 1. Create a private lock and backing storage
    private static let lock = NSLock()
    nonisolated(unsafe) private static var _ignoredDomains: [String] = []
    
    // 2. Create a computed property that manages the locking automatically
    static var ignoredDomains: [String] {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _ignoredDomains
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _ignoredDomains = newValue
        }
    }

    /// Start the Sniffer with optional ignored domains
    /// - Parameter ignoredDomains: A list of hostnames or keywords to ignore (e.g. "firebase", "google")
    public static func start(
        ignoredDomains: [String] = [
            "firebase",
            "googleapis",
            "crashlytics",
            "app-measurement",
            "analytics"
        ]
    ) {
        // This setter is now thread-safe
        self.ignoredDomains = ignoredDomains
        
        URLProtocol.registerClass(NetworkInterceptor.self)
        swizzleDefaultConfiguration()
        
        Task { @MainActor in
            DebuggerWindowManager.shared.start()
        }
    }
    
    private static func swizzleDefaultConfiguration() {
        let method = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.default))
        let swizzledMethod = class_getClassMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.swizzledDefault))
        
        if let method = method, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(method, swizzledMethod)
        }
    }
}

extension URLSessionConfiguration {
    @objc dynamic class func swizzledDefault() -> URLSessionConfiguration {
        // This actually calls the original .default because we swapped them
        let config = swizzledDefault() 
        
        // Inject our interceptor
        var protocols = config.protocolClasses ?? []
        protocols.insert(NetworkInterceptor.self, at: 0)
        config.protocolClasses = protocols
        
        return config
    }
}
