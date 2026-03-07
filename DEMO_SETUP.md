# NetworkSniffer Demo Project - Setup Summary

## ✅ What Was Created

### Demo App Files
1. **DemoApp.swift** - Main app entry point that initializes NetworkSniffer
2. **ContentView.swift** - UI with buttons for GET, POST, PUT, DELETE requests
3. **NetworkDemoViewModel.swift** - ViewModel managing API call states and logic
4. **APIService.swift** - Service layer handling actual HTTP requests

### Project Configuration
- **Xcode Project**: `NetworkSnifferDemo.xcodeproj` - Fully configured iOS app project
- **Workspace**: `NetworkSnifferDemo.xcworkspace` - Contains both demo and library
- **Package Dependency**: Local NetworkSniffer library linked via Swift Package Manager

### Documentation
- **Demo README**: `NetworkSnifferDemo/README.md` - Complete guide for using the demo
- **Main README**: Updated with demo project section

## 🚀 How to Use

### Quick Start
```bash
cd NetworkSnifferDemo
open NetworkSnifferDemo.xcodeproj
# Press Cmd+R to run
```

### What the Demo Does

1. **Initializes NetworkSniffer** on app launch with specific host filters:
   - `jsonplaceholder.typicode.com`
   - `httpbin.org`

2. **Provides Test Buttons** for:
   - **GET** - Fetches post data from JSONPlaceholder
   - **POST** - Creates a new post on JSONPlaceholder
   - **PUT** - Updates an existing post on JSONPlaceholder
   - **DELETE** - Deletes a post on JSONPlaceholder

3. **Shows NetworkSniffer UI**:
   - Floating debug button appears automatically
   - Tap to view all captured network requests
   - See request/response details, headers, body, timing

## 🔧 Technical Details

### Project Structure
```
NetworkSnifferDemo/
├── NetworkSnifferDemo.xcodeproj/     # Xcode project
├── NetworkSnifferDemo.xcworkspace/   # Workspace (optional)
├── NetworkSnifferDemo/               # Source code
│   ├── DemoApp.swift
│   ├── ContentView.swift
│   ├── NetworkDemoViewModel.swift
│   └── APIService.swift
└── README.md
```

### Dependencies
- **NetworkSniffer** library (local package at `../`)
- Minimum iOS version: 15.0
- Swift 5.9+

### Build Configuration
- Auto-generates Info.plist (no manual plist needed)
- Supports all iOS simulators and devices
- Code signing: "Sign to Run Locally"

## 🎯 Target Audience

This demo is perfect for:
- **New users** wanting to see NetworkSniffer in action
- **Developers** evaluating the library for their project
- **Testing** different HTTP methods and viewing network logs
- **Reference** on how to integrate NetworkSniffer

## 📝 Customization Examples

### Change Captured Hosts
Edit `DemoApp.swift`:
```swift
MyNetworkLib.start(capturedHosts: ["your-api.com", "another-api.com"])
```

### Add New API Endpoint
1. Add method in `APIService.swift`:
```swift
func customRequest() async throws -> String {
    let url = URL(string: "https://your-api.com/endpoint")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return String(data: data, encoding: .utf8) ?? ""
}
```

2. Add to ViewModel (`NetworkDemoViewModel.swift`):
```swift
func testCustomRequest() async {
    isLoadingCustom = true
    defer { isLoadingCustom = false }
    
    do {
        let result = try await apiService.customRequest()
        lastResponse = "Custom Success: \(result)"
    } catch {
        lastResponse = "Custom Error: \(error.localizedDescription)"
    }
}
```

3. Add button to UI (`ContentView.swift`):
```swift
APIButton(
    title: "Custom Request",
    icon: "star.circle.fill",
    color: .purple,
    isLoading: viewModel.isLoadingCustom
) {
    await viewModel.testCustomRequest()
}
```

## ✨ Features Demonstrated

- ✅ Network interception without modifying networking code
- ✅ Real-time request/response logging
- ✅ Host filtering (only capture specific domains)
- ✅ On-device debugging UI
- ✅ Support for all HTTP methods (GET, POST, PUT, DELETE)
- ✅ Works with native URLSession
- ✅ Async/await networking
- ✅ SwiftUI + Combine architecture

## 🐛 Troubleshooting

### "Cannot find NetworkSniffer in scope"
- Make sure the package dependency is properly linked
- Clean build folder: `Product > Clean Build Folder`
- Check that `add_local_package.py` script was run successfully

### Build Fails
- Delete derived data: `~/Library/Developer/Xcode/DerivedData`
- Restart Xcode
- Re-run: `python3 add_local_package.py` from root directory

### No Network Logs Appearing
- Verify `MyNetworkLib.start()` is called in `DemoApp.init()`
- Check that URLs contain the filtered hosts
- Try with empty array: `MyNetworkLib.start(capturedHosts: [])`

## 📚 Next Steps

1. **Run the demo** and explore the NetworkSniffer UI
2. **Tap all four buttons** to see different request types
3. **Open the debugger** via the floating button
4. **Inspect requests** to see headers, body, response data
5. **Integrate into your app** following the same pattern

---

**Need Help?** Check the main README or open an issue on GitHub.
