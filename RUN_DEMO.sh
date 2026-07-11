#!/bin/bash

# RUN_DEMO.sh
# Automates compiling and running the NetworkSniffer Demo App on an iOS Simulator.

# Set Developer directory for Xcode command line tools
export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"

echo "=================================================="
echo "🚀 NetworkSnifffer Demo Quick Start"
echo "=================================================="

# 1. Check for Xcode
if [ ! -d "$DEVELOPER_DIR" ]; then
    echo "❌ Error: Xcode.app not found at $DEVELOPER_DIR."
    echo "Please set DEVELOPER_DIR to your active Xcode Developer directory."
    exit 1
fi

echo "🔍 Finding available iOS Simulators..."
# Get first booted simulator, otherwise select the first shut down iPhone simulator
SIM_ID=$(xcrun simctl list devices | grep -E "Booted" | head -n 1 | sed -n 's/.*(\([A-F0-9-]*\)).*/\1/p')

if [ -z "$SIM_ID" ]; then
    echo "ℹ️ No simulator is booted. Finding default iPhone simulator to boot..."
    SIM_ID=$(xcrun simctl list devices | grep -E "iPhone" | grep -v "unavailable" | head -n 1 | sed -n 's/.*(\([A-F0-9-]\)).*/\1/p')
    
    # Fallback to general list if regex fails
    if [ -z "$SIM_ID" ]; then
        SIM_ID=$(xcrun simctl list devices | grep "iPhone" | head -n 1 | cut -d "(" -f2 | cut -d ")" -f1)
    fi
    
    if [ -z "$SIM_ID" ]; then
        echo "❌ Error: Could not find any iPhone simulators."
        exit 1
    fi
    
    echo "⚙️ Booting simulator: $SIM_ID..."
    xcrun simctl boot "$SIM_ID"
    open -a Simulator
else
    echo "✅ Found already booted simulator: $SIM_ID"
fi

# 2. Compile/Build Workspace
echo "📦 Building NetworkSnifferDemo workspace..."
cd NetworkSnifferDemo

xcodebuild build \
  -workspace NetworkSnifferDemo.xcworkspace \
  -scheme NetworkSnifferDemo \
  -destination "id=$SIM_ID" \
  -derivedDataPath ./DerivedData

if [ $? -ne 0 ]; then
    echo "❌ Build failed. Please check build logs."
    exit 1
fi
echo "✅ Build completed successfully."

# 3. Locate Built App
APP_PATH=$(find ./DerivedData -name "NetworkSnifferDemo.app" | head -n 1)

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: Could not locate built app bundle inside DerivedData."
    exit 1
fi

# 4. Install & Launch
echo "📲 Installing app to Simulator..."
xcrun simctl install "$SIM_ID" "$APP_PATH"

echo "🚀 Launching NetworkSnifferDemo app..."
# Pass AUTO_RUN_DEMO=1 to run the automated request sequence on launch
SIMCTL_CHILD_AUTO_RUN_DEMO=1 xcrun simctl launch "$SIM_ID" srinivas.co.NetworkSnifferDemo

echo "=================================================="
echo "🎉 SUCCESS!"
echo "=================================================="
echo "The demo app has been launched on your simulator."
echo "Since it launched in auto-run mode, it will:"
echo "  1. Perform 4 mock API requests (GET, POST, PUT, DELETE)."
echo "  2. Automatically open the redesigned Network Debugger Dashboard."
echo "=================================================="
