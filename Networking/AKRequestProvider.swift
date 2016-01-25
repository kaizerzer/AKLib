//
//  NetworkRequest.swift
//  Networking
//
//  Created by Anton Kaizer on 18.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import Foundation

public class AKRequestTask<T : AnyObject> {
    internal var cachedResponse: T? = nil
    public var completion: ((request: T) -> ())? = nil {
        didSet {
            if cachedResponse != nil {
                completion?(request: cachedResponse!)
            }
        }
    }
    public var failure: ((request: T, error: NSError) -> ())? = nil
    internal weak var innerTask:AKRequestInnerTask<T>?
    
    internal init(innerTask: AKRequestInnerTask<T>) {
        self.innerTask = innerTask
        innerTask.subscribe(self)
    }
    
    public func cancel() {
        innerTask?.unsubscribe(self)
    }
}

public class AKRequestProvider {
    public static let asyncQueue: NSOperationQueue = NSOperationQueue()
    
    public static var urlBuilder: AKURLBuilder = AKURLBuilder()
    public static var headersBuilder: AKHTTPHeadersBuilder = AKHTTPHeadersBuilder()
    public static var requestBodyBuilder: AKRequestBodyBuilder = AKRequestBodyBuilder()
    public static var requestSender: AKRequestSender = AKRequestSender()
    public static var responseHandlerFactory: AKResponseHandlerFactory = AKResponseHandlerFactory()
    public static var cache: AKNetworkCache = AKNetworkCache()
    
    public static let AKRequestProviderErrorDomain = "com.ak.AKRequestProvider"
    public static let AKRequestProviderBadResponseCode = 1
    public static let AKRequestProviderResponseCodeKey = "AKRequestProviderResponseCodeKey"
    public static let AKRequestProviderBadContentTypeCode = 2
    public static let AKRequestProviderContentTypeKey = "AKRequestProviderContentTypeKey"
    
    public static func send<T>(request: T) -> AKRequestTask<T> {
        let (requestInnerTask, taskFromCache) = cache.taskForRequest(request)
        let requestTask = AKRequestTask<T>(innerTask: requestInnerTask)
        if !taskFromCache {
            cache.checkIfCached(request, comletion: { (cached, reload) -> Void in
                var load = false
                if let cachedRequest = cached as? T {
                    requestTask.cachedResponse = cachedRequest
                    load = reload
                } else {
                    load = true
                }
                if load {
                    let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: urlBuilder.buildURL(request))
                    var headers:[String: String] = [:]
                    headersBuilder.fillContentType(&headers, request: request)
                    for (key, value) in headers {
                        urlRequest.setValue(value, forHTTPHeaderField: key)
                    }
                    urlRequest.HTTPMethod = headersBuilder.requestMethod(request)
                    urlRequest.HTTPBody = requestBodyBuilder.createRequestBodyData(request)
                    
                    let responseHandler = responseHandlerFactory.createResponseHandler(request, task: requestInnerTask)
                    
                    let sessionTask = requestSender.sendRequest(request, urlRequest: urlRequest, responseHandler: responseHandler)
                    requestInnerTask.urlSessionTask = sessionTask
                    sessionTask.resume()
                } else {
                    AKRequestProvider.cache.removeLoadingTask(request)
                }
            })
        }
        return requestTask
    }
}

