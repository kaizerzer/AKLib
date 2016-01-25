//
//  NSManagedObject+AKDatabase.swift
//  Networking
//
//  Created by Anton Kaizer on 24.01.16.
//  Copyright © 2016 Anton Kaizer. All rights reserved.
//

import CoreData

public extension NSManagedObject {
    public class var entityName: String { return NSStringFromClass(self).componentsSeparatedByString(".").last! }
    public class func entityDescriptionInContext(context: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName, inManagedObjectContext: context)
    }
}