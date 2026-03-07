# 🚀 Quick Start - NetworkSniffer Demo

## Run Demo in 3 Steps

```bash
# 1. Navigate to demo directory
cd NetworkSnifferDemo

# 2. Open in Xcode
open NetworkSnifferDemo.xcodeproj

# 3. Select "NetworkSnifferDemo" scheme from the dropdown (top-left in Xcode)

# 4. Press Cmd+R to run!
```

## 💡 Tip: Using the Scheme Selector

In Xcode's toolbar (top-left), you'll see a **scheme dropdown** next to the Run button.  
Click it and select **"NetworkSnifferDemo"** to run the demo app directly!

## What You'll See

✅ Four API test buttons (GET, POST, PUT, DELETE)  
✅ Response preview at bottom  
✅ Floating NetworkSniffer debug button  
✅ Full network request inspection UI  

## Quick Actions

| Action | Command |
|--------|---------|
| Open Project | `open NetworkSnifferDemo/NetworkSnifferDemo.xcodeproj` |
| Open Workspace | `open NetworkSnifferDemo/NetworkSnifferDemo.xcworkspace` |
| Clean Build | `Cmd + Shift + K` in Xcode |
| Run Demo | `Cmd + R` in Xcode |

## Files Overview

| File | Purpose |
|------|---------|
| `DemoApp.swift` | App entry, NetworkSniffer initialization |
| `ContentView.swift` | Main UI with test buttons |
| `NetworkDemoViewModel.swift` | API call logic & state |
| `APIService.swift` | HTTP request methods |

## Demo Features

🔹 **GET** - Fetch post from JSONPlaceholder  
🔹 **POST** - Create new post  
🔹 **PUT** - Update existing post  
🔹 **DELETE** - Remove post  

All requests automatically logged by NetworkSniffer!

## Documentation

📖 **NetworkSnifferDemo/README.md** - Full demo guide  
📖 **DEMO_SETUP.md** - Technical details  
📖 **DEMO_COMPLETE.md** - Complete summary  

## Need Help?

- Check inline code comments
- Read the README files
- Build succeeded ✅ - Ready to run!

---

**That's it! Open the project and press Run. Enjoy! 🎊**
