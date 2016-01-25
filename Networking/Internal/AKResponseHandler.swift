//
//  AKResponseHandler.swift
//  Networking
//
//  Created by Anton Kaizer on 20.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import Foundation

public class AKResponseHandler<T : AnyObject> {
    var task:AKRequestInnerTask<T>
    
    public var validContentTypes: [String]? = nil
    init(requestTask: AKRequestInnerTask<T>) {
        task = requestTask
    }
    
    public func statusCodeError(request: Any, urlResponse: NSHTTPURLResponse) -> NSError? {
        if urlResponse.statusCode == 200 {
            return nil
        }
        return NSError(domain: AKRequestProvider.AKRequestProviderErrorDomain,
            code: AKRequestProvider.AKRequestProviderBadResponseCode,
            userInfo: [AKRequestProvider.AKRequestProviderResponseCodeKey : urlResponse.statusCode])
    }
    
    public func headersError(request: Any, urlResponse: NSHTTPURLResponse) -> NSError? {
        if let validContentTypes = validContentTypes {
            if let contentType = urlResponse.MIMEType {
                if validContentTypes.contains(contentType) {
                    return nil
                }
            }
            return NSError(domain: AKRequestProvider.AKRequestProviderErrorDomain,
                code: AKRequestProvider.AKRequestProviderBadContentTypeCode,
                userInfo: [ AKRequestProvider.AKRequestProviderContentTypeKey : urlResponse.allHeaderFields["Content-Type"] ?? NSNull() ])
        }
        return nil
    }
    
    public func handleDataResponse(request: Any, data: NSData?, urlResponse: NSURLResponse?) {
        if let dataRequest = request as? AKDataResponse {
            dataRequest.processResponse(data)
        }
        task.complete()
    }
    
    public func validateDataResponse(request: Any, data: NSData?, urlResponse: NSURLResponse?, error: NSError?) {
        var err = error
        if err == nil {
            if let httpResponse = urlResponse as? NSHTTPURLResponse {
                err = statusCodeError(request, urlResponse: httpResponse)
                if err == nil {
                    err = headersError(request, urlResponse: httpResponse)
                }
            }
        }
        if err != nil {
            task.errorOccured(err!)
            return
        }
    }
    
    public func handleFileResponse(request: Any, file: NSURL?, urlResponse: NSURLResponse?) {
        (request as! AKFileResponse).processResponse(file!)
        task.complete()
    }
    
    public func validateFileResponse(request: Any, file: NSURL?, urlResponse: NSURLResponse?, error: NSError?) {
        var err = error
        if err == nil {
            if let httpResponse = urlResponse as? NSHTTPURLResponse {
                err = statusCodeError(request, urlResponse: httpResponse)
            }
        }
        if err != nil {
            task.errorOccured(err!)
            return
        }
    }
}