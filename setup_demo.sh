#!/bin/bash

# NetworkSniffer Demo Setup Script
# This script ensures the demo project has the NetworkSniffer library linked

echo "🚀 Setting up NetworkSniffer Demo Project..."
echo ""

# Check if we're in the right directory
if [ ! -f "Package.swift" ]; then
    echo "❌ Error: Please run this script from the NetworkSniffer root directory"
    exit 1
fi

# Check if Python3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python3 is required but not installed"
    exit 1
fi

# Check if pbxproj library is installed
if ! python3 -c "import pbxproj" 2>/dev/null; then
    echo "📦 Installing pbxproj library..."
    pip3 install pbxproj --user --quiet
    if [ $? -eq 0 ]; then
        echo "✅ pbxproj library installed"
    else
        echo "⚠️  Warning: Could not install pbxproj. You may need to add the package manually in Xcode."
    fi
fi

# Run the package linking script
if [ -f "add_local_package.py" ]; then
    echo "🔗 Linking NetworkSniffer library to demo project..."
    python3 add_local_package.py
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Demo project setup complete!"
        echo ""
        echo "📱 To run the demo:"
        echo "   1. Open NetworkSnifferDemo/NetworkSnifferDemo.xcodeproj"
        echo "   2. Select a simulator or device"
        echo "   3. Press Cmd+R to run"
        echo ""
        echo "📚 Documentation:"
        echo "   - Demo README: NetworkSnifferDemo/README.md"
        echo "   - Setup Guide: DEMO_SETUP.md"
        echo ""
    else
        echo "⚠️  Warning: Package linking may have failed. Try opening the project in Xcode and adding the package manually."
    fi
else
    echo "⚠️  Warning: add_local_package.py not found. Package may need to be added manually."
fi

# Offer to open the project
read -p "Would you like to open the demo project in Xcode now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🎯 Opening Xcode..."
    open NetworkSnifferDemo/NetworkSnifferDemo.xcodeproj
fi
