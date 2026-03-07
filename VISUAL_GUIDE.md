# 🎯 Visual Guide - Using the NetworkSnifferDemo Scheme

## Where to Find It

When you open `NetworkSnifferDemo.xcodeproj` in Xcode, look at the **top-left corner**:

```
┌──────────────────────────────────────────────────────────────┐
│  Xcode Toolbar (Top Left)                                     │
├──────────────────────────────────────────────────────────────┤
│                                                                │
│  ▶️ ⏹  ┃ NetworkSnifferDemo  >  iPhone 17  ▾ ┃             │
│         └────────┬────────┘    └─────┬─────┘                 │
│                  │                    │                        │
│           SCHEME SELECTOR      DEVICE SELECTOR                │
│         (Click this!)                                         │
│                                                                │
└──────────────────────────────────────────────────────────────┘
```

## Step-by-Step

### 1️⃣ Click the Scheme Selector

```
┌─────────────────────────────┐
│ NetworkSnifferDemo  ▾       │  ← Click here
└─────────────────────────────┘
```

### 2️⃣ You'll See the Dropdown Menu

```
┌─────────────────────────────┐
│ NetworkSnifferDemo  ▾       │
├─────────────────────────────┤
│ ✓ NetworkSnifferDemo        │ ← The demo app (select this!)
│   NetworkSnifffer           │ ← The library
├─────────────────────────────┤
│ Edit Schemes...             │
│ New Scheme...               │
│ Manage Schemes...           │
└─────────────────────────────┘
```

### 3️⃣ Select "NetworkSnifferDemo"

```
┌─────────────────────────────┐
│ ✓ NetworkSnifferDemo  ▾     │ ← Selected!
└─────────────────────────────┘
```

### 4️⃣ Press Run

```
┌──────────────────────────────────────┐
│  ▶️ ⏹  ┃ NetworkSnifferDemo > ...   │
│   ↑                                   │
│   └─ Click here OR press ⌘+R        │
└──────────────────────────────────────┘
```

## What Happens Next

### The App Launches! 🎉

```
┌─────────────────────────────────┐
│     NetworkSniffer Demo         │
│     ─────────────────            │
│                                  │
│  ┌─────────────────────────┐    │
│  │    🌐 GET Request       │    │
│  └─────────────────────────┘    │
│                                  │
│  ┌─────────────────────────┐    │
│  │    📤 POST Request      │    │
│  └─────────────────────────┘    │
│                                  │
│  ┌─────────────────────────┐    │
│  │    ✏️  PUT Request      │    │
│  └─────────────────────────┘    │
│                                  │
│  ┌─────────────────────────┐    │
│  │    🗑️  DELETE Request   │    │
│  └─────────────────────────┘    │
│                                  │
│  ┌─────────────────────────┐    │
│  │  Last Response:          │    │
│  │  Status: 200 OK          │    │
│  └─────────────────────────┘    │
│                                  │
│              🔍 ← Floating       │
│               Debug Button       │
└─────────────────────────────────┘
```

## 🎮 Test It Out!

1. **Tap GET** → Fetches data from API
2. **Look for floating button** → Bottom-right corner (🔍)
3. **Tap the floating button** → Opens NetworkSniffer UI
4. **View the captured request!** → See headers, body, response, timing

## 🌟 That's It!

No more:
- ❌ Navigating through project folders
- ❌ Finding the right target
- ❌ Confusion about what to run

Just:
- ✅ Open project
- ✅ Select "NetworkSnifferDemo" from dropdown
- ✅ Press Run!

---

**The scheme is ready and waiting in your Xcode toolbar!** 🚀
