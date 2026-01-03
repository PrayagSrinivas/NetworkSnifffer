#!/bin/sh

# --- CONFIGURATION ---
SCHEME_NAME="NetworkSnifffer"
FRAMEWORK_NAME="NetworkSnifffer"
# ---------------------

# 0. Cleanup
rm -rf archives
rm -rf "$FRAMEWORK_NAME.xcframework"
rm -f "$FRAMEWORK_NAME.xcframework.zip"

# 1. Archive for iOS Devices
echo "🚀 Building for iOS Devices..."
xcodebuild archive \
  -scheme "$SCHEME_NAME" \
  -destination "generic/platform=iOS" \
  -archivePath "archives/ios_devices.xcarchive" \
  -sdk iphoneos \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  | grep -A 5 "error:" # Only show errors to keep log clean

# 2. Archive for iOS Simulators
echo "🚀 Building for iOS Simulators..."
xcodebuild archive \
  -scheme "$SCHEME_NAME" \
  -destination "generic/platform=iOS Simulator" \
  -archivePath "archives/ios_simulators.xcarchive" \
  -sdk iphonesimulator \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
  | grep -A 5 "error:"

# 3. LOCATE THE FRAMEWORK (The Fix)
# We use 'find' to locate the framework, just in case Xcode put it in a weird folder.
DEVICE_FRAMEWORK_PATH=$(find archives/ios_devices.xcarchive -name "$FRAMEWORK_NAME.framework" -type d | head -n 1)
SIMULATOR_FRAMEWORK_PATH=$(find archives/ios_simulators.xcarchive -name "$FRAMEWORK_NAME.framework" -type d | head -n 1)

# 4. DIAGNOSE ERRORS
if [ -z "$DEVICE_FRAMEWORK_PATH" ]; then
    echo "❌ ERROR: Could not find $FRAMEWORK_NAME.framework in the device archive."
    
    # Check if it built a static library instead
    STATIC_LIB=$(find archives/ios_devices.xcarchive -name "lib$FRAMEWORK_NAME.a")
    if [ ! -z "$STATIC_LIB" ]; then
        echo "⚠️ FOUND STATIC LIBRARY INSTEAD: $STATIC_LIB"
        echo "💡 SOLUTION: You MUST add 'type: .dynamic' to your Package.swift products!"
    fi
    exit 1
fi

echo "✅ Found Device Framework: $DEVICE_FRAMEWORK_PATH"
echo "✅ Found Simulator Framework: $SIMULATOR_FRAMEWORK_PATH"

# 5. Create XCFramework
echo "📦 Creating XCFramework..."
xcodebuild -create-xcframework \
  -framework "$DEVICE_FRAMEWORK_PATH" \
  -framework "$SIMULATOR_FRAMEWORK_PATH" \
  -output "$FRAMEWORK_NAME.xcframework"

# 6. Zip and Checksum
echo "🤐 Zipping..."
zip -r "$FRAMEWORK_NAME.xcframework.zip" "$FRAMEWORK_NAME.xcframework"

echo "🎉 SUCCESS! Checksum:"
swift package compute-checksum "$FRAMEWORK_NAME.xcframework.zip"
