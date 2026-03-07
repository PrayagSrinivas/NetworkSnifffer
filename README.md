# NetworkSnifffer ⚡️

**NetworkSnifffer** is a lightweight, zero-configuration network debugging library for iOS.

It intercepts **all `URLSession` traffic** inside your app and provides a **powerful on-device dashboard** to inspect requests, responses, headers, and JSON bodies — without touching your networking code.

---
<img width="200" height="450" alt="IMG_3596" src="https://github.com/user-attachments/assets/90f84046-74c5-4d95-af51-dac96081da7b" />
<img width="200" height="450" alt="IMG_3598" src="https://github.com/user-attachments/assets/1411594b-c466-43a9-bde3-655557f3e101" />
<img width="200" height="450" alt="IMG_3599" src="https://github.com/user-attachments/assets/975cb269-4591-428f-9b87-8a4f88caaee7" />
<img width="200" height="450" alt="image" src="https://github.com/user-attachments/assets/c15ba0c6-756d-4442-a4e1-f05185d68530" />




## ✨ Features

* 🔌 **One-Line Setup:** Start intercepting network traffic instantly with a single method call.
* 📱 **On-Device Debugger:** Shake your device to reveal a full-screen network inspection dashboard.
* 🔔 **Live Traffic Badge:** *(New!)* Floating UI automatically badges incoming requests in real-time.
* 🆕 **Smart Dynamic Filters:** *(New!)* Intelligently filter network logs by HTTP method (GET, POST, PUT, DELETE) and status (Success/Failure) based on available data.
* 📊 **Comprehensive Detail View:** 4-tab interface (Summary, Request, Response, Timing) with visual timing charts for DNS, SSL, and TTFB.
* 📤 **Native Export & Copy:** *(New!)* Copy URLs, headers, or full bodies with a single tap, or use the native iOS Share Sheet to export logs instantly.
* 📄 **JSON Pretty Printing:** Automatically formats request and response JSON for easy readability.
* 🚀 **Universal Support:** Works seamlessly with both **SwiftUI** and **UIKit** apps.

---

## 📦 Installation

### Swift Package Manager (SPM)

1. Open Xcode.
2. Navigate to **File ▸ Add Packages…**
3. Enter the repository URL:
```text
https://github.com/PrayagSrinivas/NetworkSnifffer.git

```


4. Select **Up to Next Major Version → 1.0.0** (or your latest tag).
5. Click **Add Package**.

---

## 🚀 Usage

### 1️⃣ Start Network Interception

Initialize NetworkSnifffer as early as possible — ideally in your app’s entry point. You can capture all traffic, or pass specific hostnames to keep your logs clutter-free.

```swift
import NetworkSnifffer

// Capture everything:
MyNetworkLib.start() 

// OR capture only specific hosts:
MyNetworkLib.start(capturedHosts: ["firebase.com", "google.com"])

```

*💡 Call this inside `init()` (SwiftUI) or `application(_:didFinishLaunchingWithOptions:)` (UIKit).*

### 2️⃣ Present the Debugger UI

#### 🟢 SwiftUI Apps

Attach a global `.fullScreenCover` to your root view so the debugger can appear from anywhere.

```swift
import SwiftUI
import NetworkSnifffer

@main
struct MyApp: App {
    @ObservedObject private var logger = NetworkLogger.shared

    init() {
        MyNetworkLib.start(capturedHosts: ["jsonplaceholder.typicode.com"])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .fullScreenCover(isPresented: $logger.isDashboardPresented) {
                    NetworkDebuggerView()
                }
        }
    }
}

```

#### 🔵 UIKit Apps

For UIKit (Storyboard or programmatic), listen for the shake gesture and present the debugger manually.

```swift
import UIKit
import SwiftUI
import NetworkSnifffer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
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
        let debuggerVC = UIHostingController(rootView: NetworkDebuggerView())
        debuggerVC.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(debuggerVC, animated: true)
    }
}

```

---

## 🧠 How It Works

1. **Request Interception:** A custom `URLProtocol` intercepts traffic at the URL Loading System level.
2. **Session Injection:** The protocol is automatically injected into `URLSessionConfiguration.default`, allowing capture of native `URLSession` traffic and third-party libraries (e.g., Alamofire).
3. **Thread-Safe Storage:** Requests and responses are stored in a thread-safe singleton.
4. **Native UI Rendering:** A SwiftUI-based dashboard visualizes captured network data in real time.

---

## 🎯 Demo Project

Want to see NetworkSnifffer in action? Check out the included demo app!

The demo project is located in the `NetworkSnifferDemo` folder and provides a ready-to-run iOS app that demonstrates all the library's features.

### Quick Start

Run this command in your terminal from the root of the cloned repository:

```bash
./RUN_DEMO.sh

```

**Or manually:**

1. Open `NetworkSnifferDemo/NetworkSnifferDemo.xcodeproj` in Xcode.
2. Select "NetworkSnifferDemo" from the scheme dropdown (top-left).
3. Select a simulator or device.
4. Run the app (⌘+R).

### Demo Features

Tap any of the API Test Buttons (GET, POST, PUT, DELETE) to fire a real request to the JSONPlaceholder API, then tap the floating debug button to inspect the traffic!

---

## 📋 Requirements

* iOS 14.0+
* Swift 5.5+
* Xcode 13+

---

## 📄 License

NetworkSnifffer is released under the MIT License. See the `LICENSE` file for details.

---

🤝 Contributing
Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make to NetworkSnifffer are greatly appreciated!

Whether you want to fix a bug, add a new feature, or simply improve the documentation, I'd love your help.

How to Contribute:
Fork the Project
Create your Feature Branch:
Bash
git checkout -b feature/AmazingFeature
Commit your Changes:
Bash
git commit -m 'Add some AmazingFeature'
Push to the Branch:
Bash
git push origin feature/AmazingFeature
Open a Pull Request
Found a Bug or Have an Idea?
If you've found a bug or have a feature request (like adding support for specific network libraries, new UI filters, etc.), please open an issue and use the tags bug or enhancement so we can discuss it!
