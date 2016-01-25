//
//  AKDatabase.swift
//  Networking
//
//  Created by Anton Kaizer on 23.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import CoreData

public class AKDatabase {
    private static let _sharedDatabase: AKDatabase = AKDatabase()
    public class var sharedDatabase: AKDatabase {
        return _sharedDatabase
    }
    
    private lazy var documentsDir: String = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first!
    
    public var customStoreOptions: [NSObject: AnyObject]? = nil
    public var bundleDatabasePath: String? = nil
    public var useBundleDatabase: Bool = false
    private var _databsePath: String?
    public var databasePath: String {
        get {
            if useBundleDatabase && bundleDatabasePath != nil {
                return bundleDatabasePath!
            }
            if _databsePath == nil {
                let appName = NSProcessInfo.processInfo().processName.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                var asURL = NSURL(fileURLWithPath: documentsDir)
                asURL = asURL.URLByAppendingPathComponent(appName)
                _databsePath = asURL.path
            }
            return _databsePath!
        }
        set (newValue) {
            if newValue.hasPrefix(documentsDir) {
                _databsePath = newValue
            } else {
                var asURL = NSURL(fileURLWithPath: documentsDir)
                asURL = asURL.URLByAppendingPathComponent(newValue)
                _databsePath = newValue
            }
        }
    }
    
    public internal(set) var persistentStore: NSPersistentStore? = nil
    
    public internal(set) lazy var persistentStoreCoordinator:NSPersistentStoreCoordinator = {
        if !self.useBundleDatabase {
            if self.bundleDatabasePath != nil &&
            !NSFileManager.defaultManager().fileExistsAtPath(self.databasePath) {
                do {
                    try NSFileManager.defaultManager().copyItemAtPath(self.bundleDatabasePath!, toPath: self.databasePath)
                }
                catch {
                    print("AKDatabase: copying bundle database error: \(error)")
                    self.useBundleDatabase = true
                }
            }
        }
        let databaseURL:NSURL = NSURL(fileURLWithPath: self.useBundleDatabase ? self.bundleDatabasePath! : self.databasePath)
        var options: [NSObject: AnyObject] = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption : true]
        if self.useBundleDatabase {
            options[NSReadOnlyPersistentStoreOption] = true
        }
        if self.customStoreOptions != nil {
            for (k,v) in self.customStoreOptions! {
                options[k] = v
            }
        }
        
        let persistentStoreCoordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        do {
            self.persistentStore = try persistentStoreCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: databaseURL, options: options)
        } catch {
            NSLog("AKDatabase: Creating persistent store error: \(error)")
        }
        return persistentStoreCoordinator
    }()
    
    public lazy var managedObjectModel: NSManagedObjectModel = {
        return NSManagedObjectModel.mergedModelFromBundles(nil)!
    }()
    
    public internal(set) lazy var mainManagedObjectContext: NSManagedObjectContext! = {
        var result:NSManagedObjectContext? = nil
        if NSThread.currentThread() === NSThread.mainThread() {
            result = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        } else {
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                result = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            })
        }
        result?.persistentStoreCoordinator = self.persistentStoreCoordinator
        return result
    }()
    
    public func performBackgroundChanges(changesBlock: () -> Void, merge: Bool) {
        let moc = NSManagedObjectContext()
        moc.persistentStoreCoordinator = persistentStoreCoordinator
        changesBlock()
        if merge {
            var obj: NSObjectProtocol? = nil
                obj = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification, object: moc, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) -> Void in
                self.mainManagedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
                NSNotificationCenter.defaultCenter().removeObserver(obj!)
            })
        }
        do {
            try moc.save()
        } catch {
            NSLog("AKDatabase: Saving managed object context error: \(error)")
        }
        if !merge {
            self.mainManagedObjectContext.reset()
        }
    }
    
    public func createChildContext(concurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType) -> NSManagedObjectContext {
        let moc = NSManagedObjectContext(concurrencyType: concurrencyType)
        moc.parentContext = self.mainManagedObjectContext
        return moc
    }
}