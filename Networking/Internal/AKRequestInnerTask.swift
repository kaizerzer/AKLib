//
//  AKRequestInnerTask.swift
//  Networking
//
//  Created by Anton Kaizer on 23.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import Foundation

public class AKRequestInnerTask<T : AnyObject> {
    internal var urlSessionTask: NSURLSessionTask? = nil
    internal var isStopped: Bool = false
    public internal(set) var request: T
    public internal(set) var isFinished: Bool = false
    public var cancelIfNoSubscribers = true
    internal var tasks: [AKRequestTask<T>] = []
    
    internal init(request: T) {
        self.request = request
    }
    
    public func subscribe(task: AKRequestTask<T>) {
        tasks.append(task)
    }
    
    public func unsubscribe(task: AKRequestTask<T>) {
        tasks = tasks.filter({ $0 !== task })
        if tasks.count == 0 && cancelIfNoSubscribers {
            isStopped = true
            AKRequestProvider.cache.removeLoadingTask(request)
        }
    }
    
    internal func complete() {
        AKRequestProvider.cache.cache(request) { () -> Void in
            for task in self.tasks {
                task.completion?(request: self.request)
            }
            self.isFinished = true
            
            AKRequestProvider.cache.removeLoadingTask(self.request)
        }
    }
    
    internal func errorOccured(error: NSError) {
        for task in tasks {
            task.failure?(request: request, error: error)
        }
    }
}