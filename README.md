# NetworkSniffer ⚡️

**NetworkSniffer** is a lightweight, zero-configuration network debugging library for iOS.  
It intercepts **all `URLSession` traffic** inside your app and provides a **powerful on-device dashboard** to inspect requests, responses, headers, and JSON bodies — without touching your networking code.

![Platform](https://img.shields.io/badge/Platform-iOS%2014.0%2B-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## ✨ Features

- 🔌 **One-Line Setup**  
  Start intercepting network traffic instantly with a single method call.

- 📱 **On-Device Debugger**  
  Shake your device to reveal a full-screen network inspection dashboard.

- 🔍 **Search & Filter**  
  Quickly locate specific endpoints using the built-in search.

- 📄 **JSON Pretty Printing**  
  Automatically formats request and response JSON for easy readability.

- 📋 **Copy Utilities**  
  Copy URLs, headers, or full request/response bodies with a single tap.

- 🚀 **Universal Support**  
  Works seamlessly with **SwiftUI** and **UIKit** apps.

---

## 📦 Installation

### Swift Package Manager (SPM)

1. Open Xcode  
2. Navigate to **File ▸ Add Packages…**
3. Enter the repository URL:

```text
https://github.com/YourUsername/NetworkSniffer.git

	4.	Select Up to Next Major Version → 1.0.0
	5.	Click Add Package

⸻

🚀 Usage

1️⃣ Start Network Interception

Initialize NetworkSniffer as early as possible — ideally in your app’s entry point.

import NetworkSniffer

MyNetworkLib.start()

💡 Call this inside init() (SwiftUI) or application(_:didFinishLaunchingWithOptions:) (UIKit).

⸻

2️⃣ Present the Debugger UI

🟢 SwiftUI Apps
Attach a global .fullScreenCover to your root view so the debugger can appear from anywhere.

import SwiftUI
import NetworkSniffer

@main
struct MyApp: App {

    @ObservedObject private var logger = NetworkLogger.shared

    init() {
        MyNetworkLib.start()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fullScreenCover(
                    isPresented: $logger.isDashboardPresented
                ) {
                    NetworkDebuggerView()
                }
        }
    }
}


⸻

🔵 UIKit Apps
For UIKit (Storyboard or programmatic), listen for the shake gesture and present the debugger manually.

import UIKit
import SwiftUI
import NetworkSniffer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Start intercepting traffic
        MyNetworkLib.start()

        // Listen for device shake
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showDebugger),
            name: .deviceDidShake,
            object: nil
        )

        return true
    }

    @objc private func showDebugger() {
        let debuggerVC = UIHostingController(
            rootView: NetworkDebuggerView()
        )
        debuggerVC.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(debuggerVC, animated: true)
    }
}


⸻

🧠 How It Works
	1.	Request Interception
A custom URLProtocol intercepts traffic at the URL Loading System level.
	2.	Session Injection
The protocol is automatically injected into URLSessionConfiguration.default, allowing capture of:
	•	Native URLSession
	•	Third-party libraries (e.g. Alamofire)
	3.	Thread-Safe Storage
Requests and responses are stored in a thread-safe singleton.
	4.	Native UI Rendering
A SwiftUI-based dashboard visualizes captured network data in real time.

⸻

📋 Requirements
	•	iOS 14.0+
	•	Swift 5.5+
	•	Xcode 13+

⸻

📄 License

NetworkSniffer is released under the MIT License.
See the LICENSE￼ file for details.

---
