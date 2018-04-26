//
//  LocationManagerTests.swift
//  GpxLocationManagerTests
//
//  Created by Joshua Adams on 4/11/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import XCTest
import CoreLocation
import GpxLocationManager

class LocationManagerTests: XCTestCase, CLLocationManagerDelegate {
    func testInitializer() {
      let manager1 = LocationManagers(type: .gpxFile("iSmoothRun.gpx"))
      manager1.delegate = self
      let manager2 = LocationManagers(type: .locations([]))
      manager2.delegate = self
      let manager3 = LocationManagers(type: .coreLocation)
      manager3.delegate = self
    }
}
