# NetworkSniffer Demo App

This demo app showcases the NetworkSniffer library's capabilities by providing a simple interface to test various HTTP request types.

## Features

The demo app includes buttons to test:
- **GET Request**: Fetch data from a REST API
- **POST Request**: Send data to a REST API
- **PUT Request**: Update data on a REST API
- **DELETE Request**: Delete data from a REST API

All network requests are automatically intercepted and logged by the NetworkSniffer library, allowing you to view detailed information about each request and response.

## How to Run

1. **Open the project**:
   - Open `NetworkSnifferDemo.xcodeproj` in Xcode
   - Or open `NetworkSnifferDemo.xcworkspace` for workspace view

2. **Select the scheme**:
   - Choose the `NetworkSnifferDemo` scheme from the scheme selector

3. **Select a simulator or device**:
   - Choose any iOS simulator (iPhone, iPad) or a connected device
   - Minimum iOS version: 15.0

4. **Run the app**:
   - Press `Cmd + R` or click the Run button
   - The app will launch with four API test buttons

## Using the NetworkSniffer

Once the app is running:

1. **Tap any API button** (GET, POST, PUT, DELETE) to trigger a network request
2. **Access the network debugger**:
   - Look for the floating debug button that appears on the screen
   - Tap the floating button to open the NetworkSniffer debugger overlay
3. **View request details**:
   - See all captured network requests in the debugger
   - Tap on any request to view headers, body, response data, and more
   - Use filters and search to find specific requests

## API Endpoints

The demo app uses the following test APIs:
- **JSONPlaceholder** (`jsonplaceholder.typicode.com`) - A fake REST API for testing
- **HTTPBin** (`httpbin.org`) - HTTP request & response service

## Code Structure

```
NetworkSnifferDemo/
├── DemoApp.swift              # App entry point with NetworkSniffer initialization
├── ContentView.swift          # Main UI with API test buttons
├── NetworkDemoViewModel.swift # ViewModel managing API calls and state
└── APIService.swift           # Service class handling HTTP requests
```

## Customization

### Capture Specific Hosts

In `DemoApp.swift`, you can customize which hosts to capture:

```swift
MyNetworkLib.start(capturedHosts: ["jsonplaceholder.typicode.com", "httpbin.org"])
```

To capture all network traffic, pass an empty array:

```swift
MyNetworkLib.start(capturedHosts: [])
```

### Add More API Calls

To add more API testing capabilities:

1. Add a new method in `APIService.swift`
2. Add a corresponding method in `NetworkDemoViewModel.swift`
3. Add a new button in `ContentView.swift`

## Troubleshooting

### Build Issues

If you encounter build errors:
1. Clean the build folder: `Product > Clean Build Folder` (Cmd + Shift + K)
2. Delete derived data: `~/Library/Developer/Xcode/DerivedData/NetworkSnifferDemo-*`
3. Restart Xcode

### Network Debugger Not Appearing

- Make sure `MyNetworkLib.start()` is called in the app initialization
- Check that the requested URLs match the `capturedHosts` filter
- Verify the floating button is not hidden behind other UI elements

## Integration into Your Own App

To use NetworkSniffer in your own app:

1. Add the package dependency to your Xcode project
2. Import the library: `import NetworkSnifffer`
3. Start the sniffer in your app delegate or main app struct:
   ```swift
   MyNetworkLib.start(capturedHosts: ["your-api.com"])
   ```

That's it! The NetworkSniffer will automatically intercept and log all network requests.

## License

This demo app is part of the NetworkSniffer library project.
