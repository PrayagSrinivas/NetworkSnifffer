//
//  MyNetworkLib.swift
//  NetworkCall
//
//  Created by Srinivas Prayag Sahu on 26/12/25.
//


import Foundation

public class MyNetworkLib {
    
    public static func start() {
        // Register the protocol globally
        URLProtocol.registerClass(NetworkInterceptor.self)
        
        // Swizzle URLSessionConfiguration to inject our protocol automatically
        swizzleDefaultConfiguration()
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