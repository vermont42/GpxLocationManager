//
//  CDManager.swift
//  RaceRunner
//
//  Created by Joshua Adams on 2/22/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.

import Foundation
import CoreData

class CDManager {
    var context: NSManagedObjectContext!
    static let sharedCDManager = CDManager()
    
    init() {
        let modelURL = NSBundle.mainBundle().URLForResource("RaceRunner", withExtension: "momd")
        let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL!)
        let storeURL: NSURL = applicationDocumentsDirectory().URLByAppendingPathComponent("RaceRunner.sqlite")
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        }
        catch let error as NSError {
            print("\(error.localizedDescription)")
            abort()
        }
        context = NSManagedObjectContext()
        context.persistentStoreCoordinator = coordinator
    }
    
    func applicationDocumentsDirectory() -> NSURL {
        return NSURL(fileURLWithPath: NSHomeDirectory() + "/Documents/")
    }
    
    class func saveContext () {
        if let context = sharedCDManager.context {
            if context.hasChanges {
                do {
                    try context.save()
                } catch let error as NSError {
                    print("\(error.localizedDescription)")
                    abort()
                }
            }
        }
    }
}