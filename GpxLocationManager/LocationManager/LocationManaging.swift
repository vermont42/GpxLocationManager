//
//  LocationManager.swift
//  GpxLocationManager
//
//  Created by Nehal Kanetkar on 2018-04-25.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import CoreLocation

enum LocationManagerType {
  case gpx
  case locations
  case coreLocation
}

protocol LocationManaging {
  var location: CLLocation { get }
  var delegate: CLLocationManagerDelegate { get set }
  var desiredAccuracy: CLLocationAccuracy { get set }
  var activityType: CLActivityType { get set }
  var distanceFilter: CLLocationDistance { get set }
  var pausesLocationUpdatesAutomatically: Bool { get set }
  var allowsBackgroundLocationUpdates: Bool { get set }
  var monitoredRegions: Set<CLRegion> { get }

  func authorizationStatus() -> CLAuthorizationStatus
  func requestAlwaysAuthorization()
  func requestWhenInUseAuthorization()
  func startUpdatingLocation()
  func stopUpdatingLocation()
  func startMonitoringSignificantLocationChanges()
  func startMonitoring(for region: CLRegion)
  func stopMonitoring(for region: CLRegion)
  func disallowDeferredLocationUpdates()
}
