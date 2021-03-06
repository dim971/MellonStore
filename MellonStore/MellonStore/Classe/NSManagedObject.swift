//
//  NSManagedObject.swift
//  protoCoreDataConcurrency
//
//  Created by favre on 09/08/2017.
//  Copyright © 2017 adibou. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObject {
    
    /// Returns the entity class name as `String`
    class var entityName: String {
        return NSStringFromClass(self)
            .components(separatedBy: ".")
            .last!
    }
    
    /// Returns the NSEntityDescription attached to Entity A
    class var entityDescription : NSEntityDescription {
        return NSEntityDescription.entity(
            forEntityName: entityName,
            in: MellonStore.default.mainManagedObjectContext)!
    }
    
    /// Creates a new Object of type A and insert it to the given managedObjectContext
    /// if provided, other uses the default managedObjectContext provided by provider B
    ///
    /// - parameter inManagedObjectContext: The context in which the object should be inserted (optional)
    /// - returns: A new instance of the ManagedObject
    class func create(in managedObjectContext: NSManagedObjectContext = MellonStore.default.mainManagedObjectContext) throws -> Self {
        return try createAutoTyped(in: managedObjectContext)
    }
    
    /// Deletes an object from the store asynchronously
    ///
    /// The object to delete
    func delete() {
        guard let managedObjectContext = managedObjectContext else {
            return
        }
        
        managedObjectContext.perform {
            managedObjectContext.delete(self)
        }
    }
    
    /// Deletes an object from the store synchronously
    ///
    /// The object to delete
    func deleteSync() {
        guard let managedObjectContext = managedObjectContext else {
            return
        }
        
        managedObjectContext.performAndWait {
            managedObjectContext.delete(self)
            managedObjectContext.processPendingChanges()
        }
    }
    
    private class func createAutoTyped<A: NSManagedObject>(
        in managedObjectContext: NSManagedObjectContext = MellonStore.default.mainManagedObjectContext
    ) throws -> A
    {
        let object = NSEntityDescription.insertNewObject(
            forEntityName: entityName,
            into: managedObjectContext) as! A
        
        try managedObjectContext.obtainPermanentIDs(for: [object])
        
        return object
    }
}
