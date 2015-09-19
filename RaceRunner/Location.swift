//
//  Location.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/8/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import CoreData

class Location: NSManagedObject {
    @NSManaged var altitude: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var timestamp: NSDate
    @NSManaged var run: Run
}
