//
//  LocationManagerTests.swift
//  GpxLocationManagerTests
//
//  Created by Joshua Adams on 4/18/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import XCTest
import CoreLocation
import GpxLocationManager

class LocationManagerTests: XCTestCase, CLLocationManagerDelegate {
  private let gpxFile1 = "Berkeley"
  private let gpxFile2 = "Orinda"

  func testInitializer() {
    let manager1 = LocationManager(type: .gpxFile(gpxFile1))
    switch manager1.locationManagerType {
    case .gpxFile(let gpxFile):
      XCTAssertEqual(gpxFile1, gpxFile)
    default:
      XCTFail("Unexpected LocationManagerType \(manager1.locationManagerType) encountered.")
    }

    if let parser = GpxParser(file: gpxFile2) {
      let (_, savedLocations) = parser.parse()
      let manager2 = LocationManager(type: .locations(savedLocations))
      switch manager2.locationManagerType {
      case .locations(let usedLocations):
        XCTAssertEqual(savedLocations, usedLocations)
      default:
        XCTFail("Unexpected LocationManagerType \(manager2.locationManagerType) encountered.")
      }
    } else {
        XCTFail("Unable to instantiate LocationManager with LocationManagerType .locations.")
    }

    let manager3 = LocationManager(type: .coreLocation)
    switch manager3.locationManagerType {
    case .coreLocation:
      break
    default:
      XCTFail("Unexpected LocationManagerType \(manager3.locationManagerType) encountered.")
    }
  }
}
