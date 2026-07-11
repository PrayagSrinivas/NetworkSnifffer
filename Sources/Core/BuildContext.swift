//
//  BuildContext.swift
//  NetworkSnifffer
//
//  Created by Srinivas Prayag Sahu on 11/07/26.
//

import Foundation

public enum AppDistributionChannel {
    case debug         // Xcode running locally
    case simulator     // iOS Simulator
    case testFlight    // TestFlight Beta Testing
    case appStore      // Production App Store
}

public struct BuildContext {
    public static var currentChannel: AppDistributionChannel {
        #if targetEnvironment(simulator)
        return .simulator
        #elseif DEBUG
        return .debug
        #else
        // Read receipt to differentiate TestFlight vs App Store
        guard let receiptURL = Bundle.main.appStoreReceiptURL else {
            return .appStore
        }
        
        // TestFlight builds always name their receipt file "sandboxReceipt"
        if receiptURL.lastPathComponent == "sandboxReceipt" {
            return .testFlight
        }
        
        return .appStore
        #endif
    }
    
    /// Helper check to determine if the debugger should be active and visible
    public static var shouldShowDebugger: Bool {
        switch currentChannel {
        case .debug, .simulator, .testFlight:
            return true // Show for devs and beta testers
        case .appStore:
            return false // Prevent initialization in production app store
        }
    }
}
