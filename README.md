# NetworkSniffer ⚡️

**NetworkSniffer** is a lightweight, zero-configuration network debugging library for iOS.  
It intercepts **all `URLSession` traffic** inside your app and provides a **powerful on-device dashboard** to inspect requests, responses, headers, and JSON bodies — without touching your networking code.

![Platform](https://img.shields.io/badge/Platform-iOS%2014.0%2B-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.5%2B-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)
---
![Simulator Screen Recording - iPhone 17 Pro - 2026-01-03 at 17 29 19](https://github.com/user-attachments/assets/7c599a6b-3147-43ae-ab59-d23d107caa3a)
<img width="300" height="600" alt="Simulator Screenshot - iPhone 17 Pro - 2026-01-03 at 17 29 38" src="https://github.com/user-attachments/assets/3d86cfab-b02f-4dca-b022-a9a7bbd8dd97" />

## ✨ Features

- 🔌 **One-Line Setup**  
  Start intercepting network traffic instantly with a single method call.

- 📱 **On-Device Debugger**  
  Shake your device to reveal a full-screen network inspection dashboard.

- 🔍 **Search & Filter**  
  Quickly locate specific endpoints using the built-in search.

- 🆕 **Smart Dynamic Filters** *(New!)*  
  Filter network logs by HTTP method (GET, POST, PUT, DELETE) and status (Success/Failure). Filter options intelligently adapt based on available data.

- 📊 **Comprehensive Detail View**  
  4-tab interface (Summary, Request, Response, Timing) with visual timing charts, all headers, and formatted bodies.

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

    4.    Select Up to Next Major Version → 1.0.0
    5.    Click Add Package

⸻

🚀 Usage

1️⃣ Start Network Interception

Initialize NetworkSniffer as early as possible — ideally in your app’s entry point.

import NetworkSniffer

MyNetworkLib.start() or MyNetworkLib.start(capturedHosts = ["firebase", "google"]), 
You can directly use start(), but if you pass capturedHosta explictly, you will see network traffic containing capured host key word, so that i would be clutter free.

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
        MyNetworkLib.start(capturedHosts: [String] = ["xyz.com"])
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
    1.    Request Interception
A custom URLProtocol intercepts traffic at the URL Loading System level.
    2.    Session Injection
The protocol is automatically injected into URLSessionConfiguration.default, allowing capture of:
    •    Native URLSession
    •    Third-party libraries (e.g. Alamofire)
    3.    Thread-Safe Storage
Requests and responses are stored in a thread-safe singleton.
    4.    Native UI Rendering
A SwiftUI-based dashboard visualizes captured network data in real time.

⸻

## 🎯 Demo Project

Want to see NetworkSniffer in action? Check out the included demo app!

The demo project is located in the `NetworkSnifferDemo` folder and provides a ready-to-run iOS app that demonstrates all the library's features.

### Quick Start

Run this command in your terminal:
```bash
cd /Users/srinivas/Documents/NetworkSnifffer
./RUN_DEMO.sh
```

Or manually:
1. Open `NetworkSnifferDemo/NetworkSnifferDemo.xcodeproj` in Xcode
2. Select "NetworkSnifferDemo" from the scheme dropdown (top-left)
3. Select a simulator or device
4. Run the app (⌘+R)

### Demo Features

The demo app includes:
- **4 API Test Buttons**: GET, POST, PUT, DELETE
- **Real API Calls**: Makes requests to JSONPlaceholder test API
- **🆕 Smart Filters**: Try the new dynamic filter menu (tap the ☰ icon)
- **Detailed Inspection**: View comprehensive request/response details
- **Timing Analysis**: See visual timing breakdowns

Tap any button to fire an API request, then use the floating debug button (🔍) to:
- View all captured network traffic
- **Filter by method** (GET, POST, PUT, DELETE)
- **Filter by status** (Success/Failure)  
- **Search endpoints** by URL
- Inspect detailed request/response data

For more details, see the [Demo README](NetworkSnifferDemo/README.md) or [Filter Feature Guide](FILTER_FEATURE.md).

⸻

📋 Requirements
    •    iOS 14.0+
    •    Swift 5.5+
    •    Xcode 13+

⸻

📄 License

NetworkSniffer is released under the MIT License.
See the LICENSE￼ file for details.

---
