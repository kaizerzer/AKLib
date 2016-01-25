//
//  AKNetworkCache.swift
//  Networking
//
//  Created by Anton Kaizer on 21.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import Foundation

public class AKNetworkCache {
    private var tasks: [String: AnyObject] = [:]
    
    public func taskForRequest<T>(request: T) -> (task: AKRequestInnerTask<T>, fromCache: Bool) {
        var task: AKRequestInnerTask<T>? = nil
        var fromCache = false
        if let taskCache = request as? AKTaskCacheSupport {
            task = tasks[taskCache.cacheKey] as? AKRequestInnerTask<T>
        }
        if task == nil {
            task = AKRequestInnerTask<T>(request: request)
            if let memCacheTask = request as? AKMemoryCacheSupport {
                task!.cancelIfNoSubscribers = memCacheTask.shouldStopOnCancel
            }
            if let taskCache = request as? AKTaskCacheSupport {
                tasks[taskCache.cacheKey] = task
            }
        } else {
            fromCache = true
        }
        
        return (task!, fromCache)
    }
    
    func removeLoadingTask(request: AnyObject) {
        if let taskCache = request as? AKTaskCacheSupport {
            tasks.removeValueForKey(taskCache.cacheKey)
        }
    }
    
    public var memoryCache: NSCache = NSCache()
    
    public func checkIfCached(request: AnyObject, comletion: (cached: AnyObject?, reload: Bool) -> Void) {
        switch request {
        case let memCache as AKMemoryCacheSupport:
            let cachedResponse: AKMemoryCacheSupport? = memoryCache.objectForKey(memCache.cacheKey) as? AKMemoryCacheSupport
            cachedResponse?.isCached = true
            comletion(cached: cachedResponse, reload: false)
            break;
        default:
            comletion(cached: nil, reload: true)
            break;
        }
    }
    
    public func cache(request: AnyObject, completion: () -> Void) {
        switch request {
        case let memCacheRequest as AKMemoryCacheSupport:
            memoryCache.setObject(request, forKey: memCacheRequest.cacheKey)
            break;
        case let memSizedCacheRequest as AKSizedMemoryCacheSupport:
            memoryCache.setObject(request, forKey: memSizedCacheRequest.cacheKey, cost: memSizedCacheRequest.cacheSize)
            break;
        default:
            break;
        }
        completion()
    }
    
    public func removeFromCache(request: AnyObject) {
        if let memCacheRequest = request as? AKMemoryCacheSupport {
            memoryCache.removeObjectForKey(memCacheRequest.cacheKey)
        }
    }
}