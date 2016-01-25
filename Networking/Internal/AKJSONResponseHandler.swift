//
//  AKJSONResponseHandler.swift
//  Networking
//
//  Created by Anton Kaizer on 20.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import Foundation

public class AKJSONResponseHandler<T : AnyObject> : AKResponseHandler<T> {
    override init(requestTask: AKRequestInnerTask<T>) {
        super.init(requestTask: requestTask)
        validContentTypes = [ "application/json", "text/json", "text/javascript" ]
    }
    
    public func preprocessJSONResponse(request: AKJSONResponse, responceObject: AnyObject?) {
        
    }
    
    public override func handleDataResponse(request: Any, data: NSData?, urlResponse: NSURLResponse?) {
        let jsonRequest = request as! AKJSONResponse
        var responseObject:AnyObject? = nil
        if data != nil {
            
            AKRequestProvider.asyncQueue.addOperationWithBlock{
                do {
                    responseObject = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                }
                catch let error as NSError {
                    self.task.errorOccured(error)
                    return
                }
                if self.task.isStopped {
                    return
                }
                NSOperationQueue.mainQueue().addOperationWithBlock{
                    self.preprocessJSONResponse(jsonRequest, responceObject: responseObject)
                    if self.task.isStopped {
                        return
                    }
                    jsonRequest.processResponse(responseObject)
                    if self.task.isStopped {
                        return
                    }
                    self.task.complete()
                }
            }
        }
    }
}