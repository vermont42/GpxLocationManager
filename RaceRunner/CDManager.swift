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
        let modelURL = Bundle.main.url(forResource: "RaceRunner", withExtension: "momd")
        let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL!)
        let storeURL: URL = applicationDocumentsDirectory().appendingPathComponent("RaceRunner.sqlite")
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel!)
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        }
        catch let error as NSError {
            print("\(error.localizedDescription)")
            abort()
        }
        context = NSManagedObjectContext()
        context.persistentStoreCoordinator = coordinator
    }
    
    func applicationDocumentsDirectory() -> URL {
        return URL(fileURLWithPath: NSHomeDirectory() + "/Documents/")
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
