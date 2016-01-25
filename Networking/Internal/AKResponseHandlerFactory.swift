//
//  AKResponseHandlerFactory.swift
//  Networking
//
//  Created by Anton Kaizer on 21.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import Foundation

public class AKResponseHandlerFactory {
    public func createResponseHandler<T>(request: T, task: AKRequestInnerTask<T>) -> AKResponseHandler<T> {
        switch request {
        case _ as AKJSONResponse:
            return AKJSONResponseHandler<T>(requestTask: task)
        default: break
        }
        return AKResponseHandler<T>(requestTask: task)
    }
}