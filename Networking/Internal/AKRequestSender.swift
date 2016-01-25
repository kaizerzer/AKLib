//
//  AKRequestSender.swift
//  Networking
//
//  Created by Anton Kaizer on 20.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import Foundation

public class AKRequestSender {
    public func sendRequest<T>(request: T, urlRequest: NSMutableURLRequest, responseHandler: AKResponseHandler<T>) -> NSURLSessionTask {
        let session = NSURLSession.sharedSession()
        switch request {
        case _ as AKFileResponse:
            return session.downloadTaskWithRequest(urlRequest, completionHandler: { (file, response, error) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    responseHandler.validateFileResponse(request, file: file, urlResponse: response, error: error)
                    if !responseHandler.task.isStopped {
                        responseHandler.handleFileResponse(request, file: file, urlResponse: response)
                    }
                }
            })
        default:
            return session.dataTaskWithRequest(urlRequest) { (data, response, error) -> Void in
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    responseHandler.validateDataResponse(request, data: data, urlResponse: response, error: error)
                    if !responseHandler.task.isStopped {
                        responseHandler.handleDataResponse(request, data: data, urlResponse: response)
                    }
                }
            }
        }
    }
}