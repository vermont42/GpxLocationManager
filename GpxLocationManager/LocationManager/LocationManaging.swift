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
  var heading: CLHeading? { get }
  var location: CLLocation? { get }

  var delegate: CLLocationManagerDelegate? { get set }

  var pausesLocationUpdatesAutomatically: Bool { get set }
  var allowsBackgroundLocationUpdates: Bool { get set }
  var showsBackgroundLocationIndicator: Bool { get set }
  var distanceFilter: CLLocationDistance { get set }
  var desiredAccuracy: CLLocationAccuracy { get set }
  var activityType: CLActivityType { get set }

  var headingFilter: CLLocationDegrees { get set }
  var headingOrientation: CLDeviceOrientation { get set }

  var monitoredRegions: Set<CLRegion> { get }
  var maximumRegionMonitoringDistance: CLLocationDistance { get }

  var rangedRegions: Set<CLRegion> { get }

  func requestAlwaysAuthorization()
  func requestWhenInUseAuthorization()

  func authorizationStatus() -> CLAuthorizationStatus
  func locationServicesEnabled()
  func deferredLocationUpdatesAvailable()
  func significantLocationChangeMonitoringAvailable()
  func headingAvailable()
  func isMonitoringAvailable(for: AnyClass)
  func isRangingAvailable()

  func startUpdatingLocation()
  func stopUpdatingLocation()
  func requestLocation()

  func startMonitoringSignificantLocationChanges()
  func stopMonitoringSignificantLocationChanges()

  func startUpdatingHeading()
  func stopUpdatingHeading()
  func dismissHeadingCalibrationDisplay()

  func startMonitoring(for region: CLRegion)
  func stopMonitoring(for region: CLRegion)

  func startRangingBeacons(in: CLBeaconRegion)
  func stopRangingBeacons(in: CLBeaconRegion)
  func requestState(for: CLRegion)

  func startMonitoringVisits()
  func stopMonitoringVisits()

  func disallowDeferredLocationUpdates()
  func allowDeferredLocationUpdates(untilTraveled: CLLocationDistance, timeout: TimeInterval)
}
