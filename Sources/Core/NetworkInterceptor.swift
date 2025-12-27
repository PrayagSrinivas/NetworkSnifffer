//
//  NetworkInterceptor.swift
//  NetworkCall
//
//  Created by Srinivas Prayag Sahu on 26/12/25.
//


import Foundation

final class NetworkInterceptor: URLProtocol, @unchecked Sendable {
    
    // Markers to prevent infinite loops
    private static let handledKey = "MyNetworkInterceptorHandled"
    
    var dataTask: URLSessionDataTask?
    var receivedData: NSMutableData?
    var response: URLResponse?
    var startTime: Date?
    
    // 1. Determine if we should handle this request
    override class func canInit(with request: URLRequest) -> Bool {
        if URLProtocol.property(forKey: NetworkInterceptor.handledKey, in: request) != nil {
            return false
        }
        return true
    }
    
    // 2. Canonical request (usually just return the request)
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    // 3. Start loading
    override func startLoading() {
        startTime = Date()
        receivedData = NSMutableData()
        
        // Copy request and mark it as handled so we don't intercept our own forwarding
        guard let newRequest = (request as NSURLRequest).mutableCopy() as? NSMutableURLRequest else { return }
        URLProtocol.setProperty(true, forKey: NetworkInterceptor.handledKey, in: newRequest)
        
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        dataTask = session.dataTask(with: newRequest as URLRequest)
        dataTask?.resume()
    }
    
    // 4. Stop loading
    override func stopLoading() {
        dataTask?.cancel()
    }
}

// 5. Handle the response data
extension NetworkInterceptor: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        self.response = response
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        receivedData?.append(data) // Accumulate data for logging
        client?.urlProtocol(self, didLoad: data) // Pass data to original app
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
        
        // 1. EXTRACT values locally on the current thread.
        // This creates "copies" so we don't need to touch 'self' inside the Task.
        let requestToLog = self.request
        let responseToLog = self.response
        let dataToLog = self.receivedData as Data?
        let errorToLog = error
        let startTimeToLog = self.startTime ?? Date()
        
        // 2. Pass the COPIES into the Task.
        // Notice 'self' is NOT used inside the braces { ... }.
        Task { @MainActor in
            NetworkLogger.shared.log(
                request: requestToLog,
                response: responseToLog,
                responseData: dataToLog,
                error: errorToLog,
                startTime: startTimeToLog
            )
        }
    }
}
