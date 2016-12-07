//
//  GpxLocationManager.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 4/18/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import CoreLocation

public class GpxLocationManager {
    public var pausesLocationUpdatesAutomatically: Bool = true
    public var distanceFilter: CLLocationDistance =  kCLDistanceFilterNone
    public var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
    public var activityType: CLActivityType = .Other
    public var headingFilter: CLLocationDegrees = 1
    public var headingOrientation: CLDeviceOrientation = .Portrait
    public var monitoredRegions: Set<NSObject>! { get { return Set<NSObject>() } }
    public var maximumRegionMonitoringDistance: CLLocationDistance { get { return -1 } }
    public var rangedRegions: Set<NSObject>! { get { return Set<NSObject>() } }
    public var heading: CLHeading! { get { return nil } }
    public var secondLength = 1.0
    private var locations: [CLLocation] = []
    private var lastLocation = 0
    private var hasStarted = false
    private var isPaused = false
    private var callerQueue: dispatch_queue_t!
    private var updateQueue: dispatch_queue_t!
    private var dateFormatter = NSDateFormatter()
    static let dateFudge: NSTimeInterval = 1.0
    private static let dateFormat = "yyyy-MM-dd HH:mm:ss"
    private var dummyCLLocationManager: CLLocationManager!
    
    public func requestWhenInUseAuthorization() {}
    public func requestAlwaysAuthorization() {}
    public func startMonitoringSignificantLocationChanges() {}
    public func stopMonitoringSignificantLocationChanges() {}
    public func startUpdatingHeading() {}
    public func stopUpdatingHeading() {}
    public func dismissHeadingCalibrationDisplay() {}
    public func startMonitoringForRegion(region:CLRegion) {}
    public func stopMonitoringForRegion(region: CLRegion) {}
    public func startRangingBeaconsInRegion(region: CLBeaconRegion) {}
    public func stopRangingBeaconsInRegion(region: CLBeaconRegion) {}
    public func requestStateForRegion(region: CLRegion) {}
    public func startMonitoringVisits() {}
    public func stopMonitoringVisits() {}
    public func allowDeferredLocationUpdatesUntilTraveled(distance: CLLocationDistance = 0, timeout: NSTimeInterval) {}
    public func disallowDeferredLocationUpdates() {}
    public class func authorizationStatus() -> CLAuthorizationStatus { return CLAuthorizationStatus.AuthorizedAlways }
    public class func locationServicesEnabled() -> Bool { return true }
    public class func deferredLocationUpdatesAvailable() -> Bool { return true }
    public class func significantLocationChangeMonitoringAvailable() -> Bool { return true }
    public class func headingAvailable() -> Bool { return true }
    public class func isMonitoringAvailableForClass(regionClass: AnyClass! = nil) -> Bool { return true }
    public class func isRangingAvailable() -> Bool { return true }
    public var location: CLLocation! { get { return locations[lastLocation] } }
    public weak var delegate: CLLocationManagerDelegate!
    public var shouldKill = false
    
    public func startUpdatingLocation() {
        if !hasStarted {
            hasStarted = true
            dummyCLLocationManager = CLLocationManager()
            let startDate = NSDate()
            let timeInterval = round(startDate.timeIntervalSinceDate(locations[0].timestamp))
            for i in 0 ..< locations.count {
                locations[i] = CLLocation(coordinate: locations[i].coordinate, altitude: locations[i].altitude, horizontalAccuracy: locations[i].horizontalAccuracy, verticalAccuracy: locations[i].verticalAccuracy, course: locations[i].course, speed: locations[i].speed, timestamp: locations[i].timestamp.dateByAddingTimeInterval(timeInterval))
            }
            callerQueue = NSOperationQueue.currentQueue()?.underlyingQueue
            let updateQueue = dispatch_queue_create("update queue", nil)
            dispatch_async(updateQueue, {
                var currentIndex: Int = 0
                var timeIntervalSinceStart = 0.0
                var loopsCompleted = 0
                let routeDuration = round(self.locations[self.locations.count - 1].timestamp.timeIntervalSinceDate(self.locations[0].timestamp))
                while true {
                    if self.shouldKill {
                        return
                    }
                    var currentLocation = self.locations[currentIndex]
                    currentLocation = CLLocation(coordinate: currentLocation.coordinate, altitude: currentLocation.altitude, horizontalAccuracy: currentLocation.horizontalAccuracy, verticalAccuracy: currentLocation.verticalAccuracy, course: currentLocation.course, speed: currentLocation.speed, timestamp: currentLocation.timestamp.dateByAddingTimeInterval((routeDuration + NSTimeInterval(1.0)) * NSTimeInterval(loopsCompleted)))
                    if abs(currentLocation.timestamp.timeIntervalSinceDate(startDate.dateByAddingTimeInterval(timeIntervalSinceStart))) < GpxLocationManager.dateFudge {
                        if !self.isPaused {
                            dispatch_async(self.callerQueue, {
                                self.delegate.locationManager?(self.dummyCLLocationManager, didUpdateLocations: [currentLocation])

                            })
                        }
                        currentIndex++
                    }
                    timeIntervalSinceStart += 1.0
                    if currentIndex == self.locations.count {
                        currentIndex = 0
                        loopsCompleted++
                    }
                    NSThread.sleepForTimeInterval(self.secondLength)
                }
            })
        }
        else {
            self.isPaused = false
        }
    }
    
    public func stopUpdatingLocation() {
        self.isPaused = true
    }
    
    public func kill() {
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
    
    private func makeLoc(latitude: NSString, longitude: NSString, altitude: NSString, timestamp: NSString) -> CLLocation {
        return CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue), altitude: altitude.doubleValue, horizontalAccuracy: 5.0, verticalAccuracy: 5.0, timestamp: dateFormatter.dateFromString(timestamp as String)!)
    }
}
