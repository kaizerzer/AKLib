//
//  AKRequestProtocols.swift
//  Networking
//
//  Created by Anton Kaizer on 20.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import Foundation

//build URL

public protocol AKBaseURLProvider {
    var URL: String { get }
}

public protocol AKBaseAndRelativeURLProvider: AKBaseURLProvider {
    var relativePath: String? { get }
}

//request method

public protocol AKGetRequest : AKURLQueryRequest {
    
}

public protocol AKPostRequest {
    
}

//request type

public protocol AKURLQueryRequest {
    var requestBody: [String: AnyObject]? { get }
}

public protocol AKJSONRequest : AKPostRequest {
    var requestBody: AnyObject? { get }
}

//response type

public protocol AKDataResponse {
    func processResponse(response: NSData?)
}

public protocol AKJSONResponse {
    func processResponse(response: AnyObject?)
}

public protocol AKFileResponse {
    func processResponse(responseFileUrl: NSURL)
}

//cache

public protocol AKTaskCacheSupport: class {
    var cacheKey: String { get }
}

public protocol AKMemoryCacheSupport: AKTaskCacheSupport {
    var isCached: Bool { get set}
    var shouldStopOnCancel: Bool { get }
}

public protocol AKSizedMemoryCacheSupport : AKMemoryCacheSupport {
    var cacheSize: Int { get }
}
