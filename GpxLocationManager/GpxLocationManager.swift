//
//  GpxLocationManager.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 4/18/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import CoreLocation

open class GpxLocationManager {
  open var pausesLocationUpdatesAutomatically: Bool = true
  open var distanceFilter: CLLocationDistance =  kCLDistanceFilterNone
  open var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
  open var activityType: CLActivityType = .other
  open var headingFilter: CLLocationDegrees = 1
  open var headingOrientation: CLDeviceOrientation = .portrait
  open var maximumRegionMonitoringDistance: CLLocationDistance { return -1 }
  open var rangedRegions: Set<NSObject>! { return Set<NSObject>() }
  open var heading: CLHeading! { return nil }
  open var shouldRepeatLocations = false
  open var secondLength = 1.0
  open var minimumSignificantLocationUpdateDistance: CLLocationDistance = 200
  open var monitoredRegions: Set<CLRegion> = []
  private var locations: [CLLocation] = []
  private var lastLocation = 0
  private var hasStarted = false
  private var callerQueue: DispatchQueue!
  private var updateQueue: DispatchQueue!
  private var dateFormatter = DateFormatter()
  static let dateFudge: TimeInterval = 1.0
  private static let dateFormat = "yyyy-MM-dd HH:mm:ss"
  private var dummyCLLocationManager: CLLocationManager!
  private var lastDeliveredSignificantLocationUpdate: CLLocation?
  private var lastGeofenceEventLocationUpdate: CLLocation?
  private var isUpdatingLocations = false
  private var isUpdatingHeading = false
  private var isMonitoringSignificantLocationChanges = false

  open func dismissHeadingCalibrationDisplay() {}
  open func startMonitoringForRegion(_ region: CLRegion) {}
  open func stopMonitoringForRegion(_ region: CLRegion) {}
  open func startRangingBeaconsInRegion(_ region: CLBeaconRegion) {}
  open func stopRangingBeaconsInRegion(_ region: CLBeaconRegion) {}
  open func requestStateForRegion(_ region: CLRegion) {}
  open func startMonitoringVisits() {}
  open func stopMonitoringVisits() {}
  open func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance = 0, timeout: TimeInterval) {}
  open func disallowDeferredLocationUpdates() {}
  open class func authorizationStatus() -> CLAuthorizationStatus { return CLAuthorizationStatus.authorizedAlways }
  open class func locationServicesEnabled() -> Bool { return true }
  open class func deferredLocationUpdatesAvailable() -> Bool { return true }
  open class func significantLocationChangeMonitoringAvailable() -> Bool { return true }
  open class func headingAvailable() -> Bool { return true }
  open class func isMonitoringAvailableForClass(_ regionClass: AnyClass! = nil) -> Bool { return true }
  open class func isRangingAvailable() -> Bool { return true }
  open var location: CLLocation! { return locations[lastLocation] }
  open weak var delegate: CLLocationManagerDelegate!
  open var shouldKill = false
  open var shouldReset = false
  open var allowsBackgroundLocationUpdates = false

  open func startUpdatingHeading() {
    self.isUpdatingHeading = true
    startLocationUpdateMachineIfNeeded()
  }

  open func stopUpdatingHeading() {
    self.isUpdatingHeading = false
  }

  open func startUpdatingLocation() {
    self.isUpdatingLocations = true
    startLocationUpdateMachineIfNeeded()
  }

  open func requestAlwaysAuthorization() {
    self.callerQueue.async(execute: {
      self.delegate.locationManager?(self.dummyCLLocationManager, didChangeAuthorization: .authorizedAlways)
    })
  }

  open func requestWhenInUseAuthorization() {
    self.callerQueue.async(execute: {
      self.delegate.locationManager?(self.dummyCLLocationManager, didChangeAuthorization: .authorizedWhenInUse)
    })
  }

  open func startMonitoringSignificantLocationChanges() {
    isMonitoringSignificantLocationChanges = true
    startLocationUpdateMachineIfNeeded()
  }

  open func stopMonitoringSignificantLocationChanges() {
    isMonitoringSignificantLocationChanges = false
  }

  open func stopUpdatingLocation() {
    self.isUpdatingLocations = false
  }

  open func startMonitoring(for region: CLRegion) {
    self.monitoredRegions.insert(region)
    startLocationUpdateMachineIfNeeded()
  }

  open func stopMonitoring(for region: CLRegion) {
    self.monitoredRegions.remove(region)
  }

  open func kill() {
    shouldKill = true
  }

  public init() {
    callerQueue = OperationQueue.current?.underlyingQueue
    dummyCLLocationManager = CLLocationManager()
    self.locations = []
  }

  public func setLocations(gpxFile: String) {
    if let parser = GpxParser(file: gpxFile) {
      let (_, coordinates): (String, [CLLocation]) = parser.parse()
      self.locations = coordinates
      self.shouldReset = true
    }
  }

  public func setLocations(locations: [CLLocation]) {
    self.locations = locations
    self.shouldReset = true
  }

  private func startLocationUpdateMachineIfNeeded() {
    if !hasStarted {
      hasStarted = true
      let startDate = locations[0].timestamp
      let timeInterval = round(startDate.timeIntervalSince(locations[0].timestamp))
      for i in 0 ..< locations.count {
        locations[i] = CLLocation(coordinate: locations[i].coordinate, altitude: locations[i].altitude, horizontalAccuracy: locations[i].horizontalAccuracy, verticalAccuracy: locations[i].verticalAccuracy, course: locations[i].course, speed: locations[i].speed, timestamp: locations[i].timestamp.addingTimeInterval(timeInterval))
      }
      let updateQueue = DispatchQueue(label: "update queue", attributes: [])
      updateQueue.async(execute: {
        var currentIndex: Int = 0
        var timeIntervalSinceStart = 0.0
        var loopsCompleted = 0
        var hasCompletedLocations = false
        let routeDuration = round(self.locations[self.locations.count - 1].timestamp.timeIntervalSince(self.locations[0].timestamp))
        while true {
          if self.shouldKill {
            return
          }
          if self.shouldReset {
            self.shouldReset = false
            self.hasStarted = false
            self.startLocationUpdateMachineIfNeeded()
            return
          }
          var currentLocation: CLLocation!
          if hasCompletedLocations {
            let lastLoc = self.locations.last!
            currentLocation = CLLocation(coordinate: lastLoc.coordinate, altitude: lastLoc.altitude, horizontalAccuracy: lastLoc.horizontalAccuracy, verticalAccuracy: lastLoc.verticalAccuracy, course: lastLoc.course, speed: 0.0, timestamp: startDate.addingTimeInterval(timeIntervalSinceStart))
          } else {
            currentLocation = self.locations[currentIndex]

            let course: CLLocationDirection
            if self.locations.count >= currentIndex {
                let nextLocation = self.locations[currentIndex + 1]
                course = currentLocation.heading(to: nextLocation)
            } else {
                course = currentLocation.course
            }

            let timeInterval = (routeDuration + TimeInterval(1.0)) * TimeInterval(loopsCompleted) + self.secondLength // true of the previous and the current span
            let speed: CLLocationSpeed
            if currentLocation.speed != -1 && currentLocation.speed != Double.infinity {
                speed = currentLocation.speed
            } else if self.locations.count > currentIndex + 1 {
                speed = self.locations[currentIndex + 1].distance(from: currentLocation) / timeInterval
            } else {
                speed = 0
            }
            currentLocation = CLLocation(coordinate: currentLocation.coordinate, altitude: currentLocation.altitude, horizontalAccuracy: currentLocation.horizontalAccuracy, verticalAccuracy: currentLocation.verticalAccuracy, course: course, speed: speed, timestamp: currentLocation.timestamp.addingTimeInterval(timeInterval))
          }

          let timeBetweenExpectedUpdateAndNextLocation = currentLocation.timestamp.timeIntervalSince(startDate.addingTimeInterval(timeIntervalSinceStart))
          if abs(timeBetweenExpectedUpdateAndNextLocation) < GpxLocationManager.dateFudge {
            if self.isUpdatingLocations {
              self.callerQueue.async(execute: {
                self.delegate.locationManager?(self.dummyCLLocationManager, didUpdateLocations: [currentLocation])

              })
            }
            if self.isUpdatingHeading {
              let heading = GpxFakedHeading(trueNorth: currentLocation.course)
              self.callerQueue.async(execute: {
                self.delegate.locationManager?(self.dummyCLLocationManager, didUpdateHeading: heading)
              })
            }
            if self.isMonitoringSignificantLocationChanges {
              if let lastLocation = self.lastDeliveredSignificantLocationUpdate, lastLocation.distance(from: currentLocation) < self.minimumSignificantLocationUpdateDistance {
                // skip this location
              } else {
                self.lastDeliveredSignificantLocationUpdate = currentLocation
                self.callerQueue.async(execute: {
                  self.delegate.locationManager?(self.dummyCLLocationManager, didUpdateLocations: [currentLocation])

                })
              }
            }
            if let lastGeofencedLocation = self.lastGeofenceEventLocationUpdate {
              for region in self.monitoredRegions {
                if let circularRegion = region as? CLCircularRegion {
                  if circularRegion.contains(lastGeofencedLocation.coordinate) && !circularRegion.contains(currentLocation.coordinate) {
                    self.callerQueue.async(execute: {
                      self.delegate.locationManager?(self.dummyCLLocationManager, didExitRegion: circularRegion)

                    })
                  } else if !circularRegion.contains(lastGeofencedLocation.coordinate) && circularRegion.contains(currentLocation.coordinate) {
                    self.callerQueue.async(execute: {
                      self.delegate.locationManager?(self.dummyCLLocationManager, didEnterRegion: circularRegion)

                    })
                  }
                } else if region as? CLBeaconRegion != nil {
                  assertionFailure("Beacon Regions are not currently supported by GpxLocationManager!")
                }
              }
            }
            self.lastGeofenceEventLocationUpdate = currentLocation

            currentIndex += 1
          }

          if abs(timeBetweenExpectedUpdateAndNextLocation) >= GpxLocationManager.dateFudge && currentLocation.timestamp.timeIntervalSince(startDate.addingTimeInterval(timeIntervalSinceStart)) < 0 {
            // if our currentLocation is before startDate and too big to fudge, it's probably bad. skip over it without moving timeIntervalSinceStart.
            currentIndex += 1
          } else {
            timeIntervalSinceStart += 1.0
          }
          if currentIndex >= self.locations.count {
            if self.shouldRepeatLocations {
              currentIndex = 0
              loopsCompleted += 1
            } else {
              hasCompletedLocations = true
            }
          }
          Thread.sleep(forTimeInterval: self.secondLength)
        }
      })
    }
  }

  private func makeLoc(_ latitude: NSString, longitude: NSString, altitude: NSString, timestamp: NSString) -> CLLocation {
    return CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue), altitude: altitude.doubleValue, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, timestamp: dateFormatter.date(from: timestamp as String)!)
  }
}
