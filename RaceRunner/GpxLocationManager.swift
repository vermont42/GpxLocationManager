//
//  GpxLocationManager.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 4/18/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import CoreLocation

open class GpxLocationManager {
    open var pausesLocationUpdatesAutomatically: Bool = true
    open var distanceFilter: CLLocationDistance =  kCLDistanceFilterNone
    open var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    open var activityType: CLActivityType = .other
    open var headingFilter: CLLocationDegrees = 1
    open var headingOrientation: CLDeviceOrientation = .portrait
    open var monitoredRegions: Set<NSObject>! { get { return Set<NSObject>() } }
    open var maximumRegionMonitoringDistance: CLLocationDistance { get { return -1 } }
    open var rangedRegions: Set<NSObject>! { get { return Set<NSObject>() } }
    open var heading: CLHeading! { get { return nil } }
    open var secondLength = 1.0
    fileprivate var locations: [CLLocation] = []
    fileprivate var lastLocation = 0
    fileprivate var hasStarted = false
    fileprivate var isPaused = false
    fileprivate var callerQueue: DispatchQueue!
    fileprivate var updateQueue: DispatchQueue!
    fileprivate var dateFormatter = DateFormatter()
    static let dateFudge: TimeInterval = 1.0
    fileprivate static let dateFormat = "yyyy-MM-dd HH:mm:ss"
    fileprivate var dummyCLLocationManager: CLLocationManager!
    
    open func requestWhenInUseAuthorization() {}
    open func requestAlwaysAuthorization() {}
    open func startMonitoringSignificantLocationChanges() {}
    open func stopMonitoringSignificantLocationChanges() {}
    open func startUpdatingHeading() {}
    open func stopUpdatingHeading() {}
    open func dismissHeadingCalibrationDisplay() {}
    open func startMonitoringForRegion(_ region:CLRegion) {}
    open func stopMonitoringForRegion(_ region: CLRegion) {}
    open func startRangingBeaconsInRegion(_ region: CLBeaconRegion) {}
    open func stopRangingBeaconsInRegion(_ region: CLBeaconRegion) {}
    open func requestStateForRegion(_ region: CLRegion) {}
    open func startMonitoringVisits() {}
    open func stopMonitoringVisits() {}
    open func allowDeferredLocationUpdatesUntilTraveled(_ distance: CLLocationDistance = 0, timeout: TimeInterval) {}
    open func disallowDeferredLocationUpdates() {}
    open class func authorizationStatus() -> CLAuthorizationStatus { return CLAuthorizationStatus.authorizedAlways }
    open class func locationServicesEnabled() -> Bool { return true }
    open class func deferredLocationUpdatesAvailable() -> Bool { return true }
    open class func significantLocationChangeMonitoringAvailable() -> Bool { return true }
    open class func headingAvailable() -> Bool { return true }
    open class func isMonitoringAvailableForClass(_ regionClass: AnyClass! = nil) -> Bool { return true }
    open class func isRangingAvailable() -> Bool { return true }
    open var location: CLLocation! { get { return locations[lastLocation] } }
    open weak var delegate: CLLocationManagerDelegate!
    open var shouldKill = false
    
    open func startUpdatingLocation() {
        if !hasStarted {
            hasStarted = true
            dummyCLLocationManager = CLLocationManager()
            let startDate = Date()
            let timeInterval = round(startDate.timeIntervalSince(locations[0].timestamp))
            for i in 0 ..< locations.count {
                locations[i] = CLLocation(coordinate: locations[i].coordinate, altitude: locations[i].altitude, horizontalAccuracy: locations[i].horizontalAccuracy, verticalAccuracy: locations[i].verticalAccuracy, course: locations[i].course, speed: locations[i].speed, timestamp: locations[i].timestamp.addingTimeInterval(timeInterval))
            }
            callerQueue = OperationQueue.current?.underlyingQueue
            let updateQueue = DispatchQueue(label: "update queue", attributes: [])
            updateQueue.async(execute: {
                var currentIndex: Int = 0
                var timeIntervalSinceStart = 0.0
                var loopsCompleted = 0
                let routeDuration = round(self.locations[self.locations.count - 1].timestamp.timeIntervalSince(self.locations[0].timestamp))
                while true {
                    if self.shouldKill {
                        return
                    }
                    var currentLocation = self.locations[currentIndex]
                    currentLocation = CLLocation(coordinate: currentLocation.coordinate, altitude: currentLocation.altitude, horizontalAccuracy: currentLocation.horizontalAccuracy, verticalAccuracy: currentLocation.verticalAccuracy, course: currentLocation.course, speed: currentLocation.speed, timestamp: currentLocation.timestamp.addingTimeInterval((routeDuration + TimeInterval(1.0)) * TimeInterval(loopsCompleted)))
                    if abs(currentLocation.timestamp.timeIntervalSince(startDate.addingTimeInterval(timeIntervalSinceStart))) < GpxLocationManager.dateFudge {
                        if !self.isPaused {
                            self.callerQueue.async(execute: {
                                self.delegate.locationManager?(self.dummyCLLocationManager, didUpdateLocations: [currentLocation])

                            })
                        }
                        currentIndex += 1
                    }
                    timeIntervalSinceStart += 1.0
                    if currentIndex == self.locations.count {
                        currentIndex = 0
                        loopsCompleted += 1
                    }
                    Thread.sleep(forTimeInterval: self.secondLength)
                }
            })
        }
        else {
            self.isPaused = false
        }
    }
    
    open func stopUpdatingLocation() {
        self.isPaused = true
    }
    
    open func kill() {
        shouldKill = true
    }
    
    public init() {
        abort()
    }
    
    public init(gpxFile: String) {
        if let parser = GpxParser(file: gpxFile) {
            let (_, coordinates): (String, [CLLocation]) = parser.parse()
            self.locations = coordinates
        }
        else {
            abort()
        }
    }
    
    public init(locations: [CLLocation]) {
        self.locations = locations
    }
    
    fileprivate func makeLoc(_ latitude: NSString, longitude: NSString, altitude: NSString, timestamp: NSString) -> CLLocation {
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue), altitude: altitude.doubleValue, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, timestamp: dateFormatter.date(from: timestamp as String)!)
    }
}
