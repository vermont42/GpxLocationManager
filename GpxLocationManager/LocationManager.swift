//
//  LocationManager.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 4/23/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import CoreLocation

open class LocationManager {
  private var gpxLocationManager: GpxLocationManager!
  private var cLLocationManager: CLLocationManager!

  public enum LocationManagerType {
    case gpxFile(String)
    case locations([CLLocation])
    case coreLocation

    init() {
      self = .coreLocation
    }
  }

  open func authorizationStatus() -> CLAuthorizationStatus {
    switch locationManagerType {
    case .gpxFile, .locations:
      return GpxLocationManager.authorizationStatus()
    case .coreLocation:
      return CLLocationManager.authorizationStatus()
    }
  }

  open var location: CLLocation! {
    get {
      switch locationManagerType {
      case .gpxFile, .locations:
        return gpxLocationManager.location
      case .coreLocation:
        return cLLocationManager.location
      }
    }
  }

  open weak var delegate: CLLocationManagerDelegate! {
    get {
      switch locationManagerType {
      case .gpxFile, .locations:
        return gpxLocationManager.delegate
      case .coreLocation:
        return cLLocationManager.delegate
      }
    }
    set {
      switch locationManagerType {
      case .gpxFile, .locations:
        gpxLocationManager.delegate = newValue
      case .coreLocation:
        cLLocationManager.delegate = newValue
      }
    }
  }

  open var desiredAccuracy: CLLocationAccuracy {
    get {
      switch locationManagerType {
      case .gpxFile, .locations:
        return gpxLocationManager.desiredAccuracy
      case .coreLocation:
        return cLLocationManager.desiredAccuracy
      }
    }
    set {
      switch locationManagerType {
      case .gpxFile, .locations:
        gpxLocationManager.desiredAccuracy = newValue
      case .coreLocation:
        cLLocationManager.desiredAccuracy = newValue
      }
    }
  }

  open var activityType: CLActivityType {
    get {
      switch locationManagerType {
      case .gpxFile, .locations:
        return gpxLocationManager.activityType
      case .coreLocation:
        return cLLocationManager.activityType
      }
    }
    set {
      switch locationManagerType {
      case .gpxFile, .locations:
        gpxLocationManager.activityType = newValue
      case .coreLocation:
        cLLocationManager.activityType = newValue
      }
    }
  }

  open var distanceFilter: CLLocationDistance {
    get {
      switch locationManagerType {
      case .gpxFile, .locations:
        return gpxLocationManager.distanceFilter
      case .coreLocation:
        return cLLocationManager.distanceFilter
      }
    }
    set {
      switch locationManagerType {
      case .gpxFile, .locations:
        gpxLocationManager.distanceFilter = newValue
      case .coreLocation:
        cLLocationManager.distanceFilter = newValue
      }
    }
  }

  open var pausesLocationUpdatesAutomatically: Bool {
    get {
      switch locationManagerType {
      case .gpxFile, .locations:
        return gpxLocationManager.pausesLocationUpdatesAutomatically
      case .coreLocation:
        return cLLocationManager.pausesLocationUpdatesAutomatically
      }
    }
    set {
      switch locationManagerType {
      case .gpxFile, .locations:
        gpxLocationManager.pausesLocationUpdatesAutomatically = newValue
      case .coreLocation:
        cLLocationManager.pausesLocationUpdatesAutomatically = newValue
      }
    }
  }

  open var allowsBackgroundLocationUpdates: Bool {
    get {
      switch locationManagerType {
      case .gpxFile, .locations:
        return gpxLocationManager.allowsBackgroundLocationUpdates
      case .coreLocation:
        return cLLocationManager.allowsBackgroundLocationUpdates
      }
    }
    set {
      switch locationManagerType {
      case .gpxFile, .locations:
        gpxLocationManager.allowsBackgroundLocationUpdates = newValue
      case .coreLocation:
        cLLocationManager.allowsBackgroundLocationUpdates = newValue
      }
    }
  }

  open func requestAlwaysAuthorization() {
    switch locationManagerType {
    case .gpxFile, .locations:
      gpxLocationManager.requestAlwaysAuthorization()
    case .coreLocation:
      cLLocationManager.requestAlwaysAuthorization()
    }
  }

  open func requestWhenInUseAuthorization() {
    switch locationManagerType {
    case .gpxFile, .locations:
      gpxLocationManager.requestWhenInUseAuthorization()
    case .coreLocation:
      cLLocationManager.requestWhenInUseAuthorization()
    }
  }

  open var secondLength: Double {
    get {
      switch locationManagerType {
      case .gpxFile, .locations:
        return gpxLocationManager.secondLength
      case .coreLocation:
        return 1.0
      }
    }
    set {
      switch locationManagerType {
      case .gpxFile, .locations:
        gpxLocationManager.secondLength = newValue
      case .coreLocation:
        break
      }
    }
  }

  open func kill() {
    switch locationManagerType {
    case .gpxFile, .locations:
      gpxLocationManager.kill()
    case .coreLocation:
      break
    }
  }

  open let locationManagerType: LocationManagerType

  public init(type: LocationManagerType) {
    locationManagerType = type
    switch type {
    case .gpxFile(let gpxFile):
      gpxLocationManager = GpxLocationManager()
      setLocations(gpxFile: gpxFile)
    case .locations(let locations):
      gpxLocationManager = GpxLocationManager()
      setLocations(locations: locations)
    case .coreLocation:
      cLLocationManager = CLLocationManager()
    }
  }

  public init() {
    locationManagerType = .coreLocation
    cLLocationManager = CLLocationManager()
  }

  public func setLocations(gpxFile: String) {
    switch locationManagerType {
    case .gpxFile(_):
      gpxLocationManager.setLocations(gpxFile: gpxFile)
    case .locations:
      fatalError("locationManagerType of this instance is .locations but GPX filename was passed.")
    case .coreLocation:
      fatalError("locationManagerType of this instance is .coreLocation but GPX filename was passed.")
    }
  }

  public func setLocations(locations: [CLLocation]) {
    switch locationManagerType {
    case .gpxFile, .locations:
      gpxLocationManager.setLocations(locations: locations)
    case .coreLocation:
      fatalError("locationManagerType of this instance is .coreLocation but caller attempted to set locations.")
    }
  }

  open func stopUpdatingLocation() {
    switch locationManagerType {
    case .gpxFile, .locations:
      gpxLocationManager.stopUpdatingLocation()
    case .coreLocation:
      cLLocationManager.stopUpdatingLocation()
    }
  }

  open func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance, timeout: TimeInterval) {
    switch locationManagerType {
    case .gpxFile, .locations:
      gpxLocationManager.allowDeferredLocationUpdates(untilTraveled: distance, timeout: timeout)
    case .coreLocation:
      cLLocationManager.allowDeferredLocationUpdates(untilTraveled: distance, timeout: timeout)
    }
  }

  open func disallowDeferredLocationUpdates() {
    switch locationManagerType {
    case .gpxFile, .locations:
      gpxLocationManager.disallowDeferredLocationUpdates()
    case .coreLocation:
      cLLocationManager.disallowDeferredLocationUpdates()
    }
  }

  var monitoredRegions: Set<CLRegion> {
    get {
      switch locationManagerType {
      case .gpxFile, .locations:
        return gpxLocationManager.monitoredRegions
      case .coreLocation:
        return cLLocationManager.monitoredRegions
      }
    }
  }

  open func stopMonitoring(for region: CLRegion) {
    switch locationManagerType {
    case .gpxFile, .locations:
      gpxLocationManager.stopMonitoring(for: region)
    case .coreLocation:
      cLLocationManager.stopMonitoring(for: region)
    }
  }

  open func startMonitoring(for region: CLRegion) {
    switch locationManagerType {
    case .gpxFile, .locations:
      gpxLocationManager.startMonitoring(for: region)
    case .coreLocation:
      cLLocationManager.startMonitoring(for: region)
    }
  }

  open func startMonitoringSignificantLocationChanges() {
    switch locationManagerType {
    case .gpxFile, .locations:
      gpxLocationManager.startMonitoringSignificantLocationChanges()
    case .coreLocation:
      cLLocationManager.startMonitoringSignificantLocationChanges()
    }
  }

  open func startUpdatingLocation() {
    switch locationManagerType {
    case .gpxFile, .locations:
      gpxLocationManager.startUpdatingLocation()
    case .coreLocation:
      cLLocationManager.startUpdatingLocation()
    }
  }
}
