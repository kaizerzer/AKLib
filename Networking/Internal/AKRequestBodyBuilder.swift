//
//  AKRequestBodyBuilder.swift
//  Networking
//
//  Created by Anton Kaizer on 20.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import Foundation

public class AKRequestBodyBuilder {
    public func createRequestBodyData(request: Any) -> NSData?  {
        switch request {
        case let jsonSource as AKJSONRequest:
            if let data = jsonSource.requestBody {
                return try? NSJSONSerialization.dataWithJSONObject(data, options: [])
            }
        default: break
        }
        return nil
    }
}