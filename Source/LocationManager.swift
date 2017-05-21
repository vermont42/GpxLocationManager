//
//  LocationManager.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 4/23/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import CoreLocation

open class LocationManager {
    fileprivate var gpxLocationManager: GpxLocationManager!
    fileprivate var cLLocationManager: CLLocationManager!
    public enum LocationManagerType {
        case gpx, coreLocation
        init() {
            self = .coreLocation
        }
    }
    open func authorizationStatus() -> CLAuthorizationStatus {
        switch locationManagerType {
        case .gpx:
            return GpxLocationManager.authorizationStatus()
        case .coreLocation:
            return CLLocationManager.authorizationStatus()
        }
    }
    open var location: CLLocation! {
        get {
            switch locationManagerType {
            case .gpx:
                return gpxLocationManager.location
            case .coreLocation:
                return cLLocationManager.location
            }
        }
    }
    open weak var delegate: CLLocationManagerDelegate! {
        get {
            switch locationManagerType {
            case .gpx:
                return gpxLocationManager.delegate
            case .coreLocation:
                return cLLocationManager.delegate
            }
        }
        set {
            switch locationManagerType {
            case .gpx:
                gpxLocationManager.delegate = newValue
            case .coreLocation:
                cLLocationManager.delegate = newValue
            }
        }
    }
    open var desiredAccuracy: CLLocationAccuracy {
        get {
            switch locationManagerType {
            case .gpx:
                return gpxLocationManager.desiredAccuracy
            case .coreLocation:
                return cLLocationManager.desiredAccuracy
            }
        }
        set {
            switch locationManagerType {
            case .gpx:
                gpxLocationManager.desiredAccuracy = newValue
            case .coreLocation:
                cLLocationManager.desiredAccuracy = newValue
            }
        }
    }
    open var activityType: CLActivityType {
        get {
            switch locationManagerType {
            case .gpx:
                return gpxLocationManager.activityType
            case .coreLocation:
                return cLLocationManager.activityType
            }
        }
        set {
            switch locationManagerType {
            case .gpx:
                gpxLocationManager.activityType = newValue
            case .coreLocation:
                cLLocationManager.activityType = newValue
            }
        }
    }
    open var distanceFilter: CLLocationDistance {
        get {
            switch locationManagerType {
            case .gpx:
                return gpxLocationManager.distanceFilter
            case .coreLocation:
                return cLLocationManager.distanceFilter
            }
        }
        set {
            switch locationManagerType {
            case .gpx:
                gpxLocationManager.distanceFilter = newValue
            case .coreLocation:
                cLLocationManager.distanceFilter = newValue
            }
        }
    }
    open var pausesLocationUpdatesAutomatically: Bool {
        get {
            switch locationManagerType {
            case .gpx:
                return gpxLocationManager.pausesLocationUpdatesAutomatically
            case .coreLocation:
                return cLLocationManager.pausesLocationUpdatesAutomatically
            }
        }
        set {
            switch locationManagerType {
            case .gpx:
                gpxLocationManager.pausesLocationUpdatesAutomatically = newValue
            case .coreLocation:
                cLLocationManager.pausesLocationUpdatesAutomatically = newValue
            }
        }
    }
    @available(iOS 9.0, *)
    open var allowsBackgroundLocationUpdates: Bool {
        get {
            switch locationManagerType {
            case .gpx:
                return gpxLocationManager.allowsBackgroundLocationUpdates
            case .coreLocation:
                return cLLocationManager.allowsBackgroundLocationUpdates
            }
        }
        set {
            switch locationManagerType {
            case .gpx:
                gpxLocationManager.allowsBackgroundLocationUpdates = newValue
            case .coreLocation:
                cLLocationManager.allowsBackgroundLocationUpdates = newValue
            }
        }
    }
    open func requestAlwaysAuthorization() {
        switch locationManagerType {
        case .gpx:
            gpxLocationManager.requestAlwaysAuthorization()
        case .coreLocation:
            cLLocationManager.requestAlwaysAuthorization()
        }
    }
    open var secondLength: Double {
        get {
            switch locationManagerType {
            case .gpx:
                return gpxLocationManager.secondLength
            case .coreLocation:
                return 1.0
            }
        }
        set {
            switch locationManagerType {
            case .gpx:
                gpxLocationManager.secondLength = newValue
            case .coreLocation:
                break
            }
        }
    }
    open func kill() {
        switch locationManagerType {
        case .gpx:
            gpxLocationManager.kill()
        case .coreLocation:
            break
        }
    }

    open let locationManagerType: LocationManagerType
    
    public init(type: LocationManagerType) {
        switch type {
        case .gpx:
            gpxLocationManager = GpxLocationManager()
        case .coreLocation:
            cLLocationManager = CLLocationManager()
        }
        
        locationManagerType = type
    }
    
    public func setLocations(gpxFile: String) {
        switch locationManagerType {
        case .gpx:
            gpxLocationManager.setLocations(gpxFile: gpxFile)
        case .coreLocation:
            return
        }
    }
    
    public func setLocations(locations: [CLLocation]) {
        switch locationManagerType {
        case .gpx:
            gpxLocationManager.setLocations(locations: locations)
        case .coreLocation:
            return
        }
    }
    
    open func stopUpdatingLocation() {
        switch locationManagerType {
        case .gpx:
            gpxLocationManager.stopUpdatingLocation()
        case .coreLocation:
            cLLocationManager.stopUpdatingLocation()
        }
    }
    
    open func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance, timeout: TimeInterval) {
        switch locationManagerType {
        case .gpx:
            gpxLocationManager.allowDeferredLocationUpdates(untilTraveled: distance, timeout: timeout)
        case .coreLocation:
            cLLocationManager.allowDeferredLocationUpdates(untilTraveled: distance, timeout: timeout)
        }
    }
    
    open func disallowDeferredLocationUpdates() {
        switch locationManagerType {
        case .gpx:
            gpxLocationManager.disallowDeferredLocationUpdates()
        case .coreLocation:
            cLLocationManager.disallowDeferredLocationUpdates()
        }
    }
    
    var monitoredRegions: Set<CLRegion> {
        get {
            switch locationManagerType {
            case .gpx:
                return gpxLocationManager.monitoredRegions
            case .coreLocation:
                return cLLocationManager.monitoredRegions
            }
        }
    }
    
    open func stopMonitoring(for region: CLRegion) {
        switch locationManagerType {
        case .gpx:
            gpxLocationManager.stopMonitoring(for: region)
        case .coreLocation:
            cLLocationManager.stopMonitoring(for: region)
        }
    }
    
    open func startMonitoring(for region: CLRegion) {
        switch locationManagerType {
        case .gpx:
            gpxLocationManager.startMonitoring(for: region)
        case .coreLocation:
            cLLocationManager.startMonitoring(for: region)
        }
    }
    
    open func startMonitoringSignificantLocationChanges() {
        switch locationManagerType {
        case .gpx:
            gpxLocationManager.startMonitoringSignificantLocationChanges()
        case .coreLocation:
            cLLocationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    open func startUpdatingLocation() {
        switch locationManagerType {
        case .gpx:
            gpxLocationManager.startUpdatingLocation()
        case .coreLocation:
            cLLocationManager.startUpdatingLocation()
        }
    }
    
}
