//
//  AKURLBuilder.swift
//  Networking
//
//  Created by Anton Kaizer on 20.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//
import Foundation

public class AKURLBuilder {
    public func buildURL(request: Any) -> NSURL {
        var URL: NSURL? = nil
        switch request {
        case let urlSource as AKBaseAndRelativeURLProvider:
            var urlString = urlSource.URL
            if urlSource.relativePath != nil {
                urlString = (urlString as NSString).stringByAppendingPathComponent(urlSource.relativePath!)
            }
            URL = NSURL(string: urlString)
            break;
        case let urlSources as AKBaseURLProvider:
            URL = NSURL(string: urlSources.URL)
            break;
        default:
            assertionFailure("AKURLBuilder: request must implent AKBaseURLProvider or AKBaseAndRelativeURLProvider")
        }
        if let getRequest = request as? AKURLQueryRequest,
            let requestBody = getRequest.requestBody {
                URL = NSURL(string: URL!.absoluteString + AKURLBuilder.convertURLQueryToStringFromDictionary(requestBody)!)!
            }
        return URL!
    }
    
    public static func convertURLQueryToStringFromDictionary(query: [String: AnyObject]?) -> String? {
        if query != nil {
            var result:String = ""
            self.append("", value: query!, result: &result)
            return result
        }
        return nil
    }
    
    private static func encodeQueryString(value: String) -> String {
        return value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
    }
    private static func append(key: String, value:AnyObject, inout result: String) {
        
        if let dict = value as? NSDictionary {
            dict.enumerateKeysAndObjectsUsingBlock { (k, v, stop) in
                let encodedKey = encodeQueryString(k.description)
                self.append(key.isEmpty ? encodedKey : "\(key)[\(encodedKey)]", value: v, result: &result)
            }
        } else if let array = value as? NSArray {
            array.enumerateObjectsUsingBlock({ (v, index, stop) -> Void in
                self.append("\(key)[]", value: v, result: &result)
            })
        } else {
            result += (result.isEmpty ? "?" : "&") + "\(key)=" + encodeQueryString(value.description)
        }
    }
}