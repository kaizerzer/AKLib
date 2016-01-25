//
//  AKHTTPHeadersBuilder.swift
//  Networking
//
//  Created by Anton Kaizer on 20.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import Foundation

public class AKHTTPHeadersBuilder {
    public func fillContentType(inout headers:[String: String], request: Any) {
        switch request {
        case _ as AKJSONRequest:
            headers["Content-Type"] = "application/json; charset=utf-8"
            break;
        default:
            break;
        }
    }
    public func requestMethod(request: Any) -> String {
        switch request {
        case _ as AKPostRequest:
            return "POST"
        default:
            return "GET"
        }
    }
}