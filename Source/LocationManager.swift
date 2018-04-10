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
        case cLLocationManager

        init() {
            self = .cLLocationManager
        }
    }

    open func authorizationStatus() -> CLAuthorizationStatus {
        switch locationManagerType {
        case .gpxFile, .locations:
            return GpxLocationManager.authorizationStatus()
        case .cLLocationManager:
            return CLLocationManager.authorizationStatus()
        }
    }

    open var location: CLLocation! {
        get {
            switch locationManagerType {
            case .gpxFile, .locations:
                return gpxLocationManager.location
            case .cLLocationManager:
                return cLLocationManager.location
            }
        }
    }

    open weak var delegate: CLLocationManagerDelegate! {
        get {
            switch locationManagerType {
            case .gpxFile, .locations:
                return gpxLocationManager.delegate
            case .cLLocationManager:
                return cLLocationManager.delegate
            }
        }
        set {
            switch locationManagerType {
            case .gpxFile, .locations:
                gpxLocationManager.delegate = newValue
            case .cLLocationManager:
                cLLocationManager.delegate = newValue
            }
        }
    }

    open var desiredAccuracy: CLLocationAccuracy {
        get {
            switch locationManagerType {
            case .gpxFile, .locations:
                return gpxLocationManager.desiredAccuracy
            case .cLLocationManager:
                return cLLocationManager.desiredAccuracy
            }
        }
        set {
            switch locationManagerType {
            case .gpxFile, .locations:
                gpxLocationManager.desiredAccuracy = newValue
            case .cLLocationManager:
                cLLocationManager.desiredAccuracy = newValue
            }
        }
    }

    open var activityType: CLActivityType {
        get {
            switch locationManagerType {
            case .gpxFile, .locations:
                return gpxLocationManager.activityType
            case .cLLocationManager:
                return cLLocationManager.activityType
            }
        }
        set {
            switch locationManagerType {
            case .gpxFile, .locations:
                gpxLocationManager.activityType = newValue
            case .cLLocationManager:
                cLLocationManager.activityType = newValue
            }
        }
    }

    open var distanceFilter: CLLocationDistance {
        get {
            switch locationManagerType {
            case .gpxFile, .locations:
                return gpxLocationManager.distanceFilter
            case .cLLocationManager:
                return cLLocationManager.distanceFilter
            }
        }
        set {
            switch locationManagerType {
            case .gpxFile, .locations:
                gpxLocationManager.distanceFilter = newValue
            case .cLLocationManager:
                cLLocationManager.distanceFilter = newValue
            }
        }
    }

    open var pausesLocationUpdatesAutomatically: Bool {
        get {
            switch locationManagerType {
            case .gpxFile, .locations:
                return gpxLocationManager.pausesLocationUpdatesAutomatically
            case .cLLocationManager:
                return cLLocationManager.pausesLocationUpdatesAutomatically
            }
        }
        set {
            switch locationManagerType {
            case .gpxFile, .locations:
                gpxLocationManager.pausesLocationUpdatesAutomatically = newValue
            case .cLLocationManager:
                cLLocationManager.pausesLocationUpdatesAutomatically = newValue
            }
        }
    }

    open var allowsBackgroundLocationUpdates: Bool {
        get {
            switch locationManagerType {
            case .gpxFile, .locations:
                return gpxLocationManager.allowsBackgroundLocationUpdates
            case .cLLocationManager:
                return cLLocationManager.allowsBackgroundLocationUpdates
            }
        }
        set {
            switch locationManagerType {
            case .gpxFile, .locations:
                gpxLocationManager.allowsBackgroundLocationUpdates = newValue
            case .cLLocationManager:
                cLLocationManager.allowsBackgroundLocationUpdates = newValue
            }
        }
    }

    open func requestAlwaysAuthorization() {
        switch locationManagerType {
        case .gpxFile, .locations:
            gpxLocationManager.requestAlwaysAuthorization()
        case .cLLocationManager:
            cLLocationManager.requestAlwaysAuthorization()
        }
    }

    open var secondLength: Double {
        get {
            switch locationManagerType {
            case .gpxFile, .locations:
                return gpxLocationManager.secondLength
            case .cLLocationManager:
                return 1.0
            }
        }
        set {
            switch locationManagerType {
            case .gpxFile, .locations:
                gpxLocationManager.secondLength = newValue
            case .cLLocationManager:
                break
            }
        }
    }

    open func kill() {
        switch locationManagerType {
        case .gpxFile, .locations:
            gpxLocationManager.kill()
        case .cLLocationManager:
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
        case .cLLocationManager:
            cLLocationManager = CLLocationManager()
        }
    }

    public init() {
        locationManagerType = .cLLocationManager
        cLLocationManager = CLLocationManager()
    }
    
    public func setLocations(gpxFile: String) {
        switch locationManagerType {
        case .gpxFile:
            gpxLocationManager.setLocations(gpxFile: gpxFile)
        case .locations:
            fatalError("locationManagerType of this instance is .locations but GPX filename was passed.")
        case .cLLocationManager:
            fatalError("locationManagerType of this instance is .cLLocationManager but GPX filename was passed.")
        }
    }
    
    public func setLocations(locations: [CLLocation]) {
        switch locationManagerType {
        case .gpxFile, .locations:
            gpxLocationManager.setLocations(locations: locations)
        case .cLLocationManager:
            fatalError("locationManagerType of this instance is .cLLocationManager but caller attempted to set locations.")
        }
    }
    
    open func stopUpdatingLocation() {
        switch locationManagerType {
        case .gpxFile, .locations:
            gpxLocationManager.stopUpdatingLocation()
        case .cLLocationManager:
            cLLocationManager.stopUpdatingLocation()
        }
    }
    
    open func allowDeferredLocationUpdates(untilTraveled distance: CLLocationDistance, timeout: TimeInterval) {
        switch locationManagerType {
        case .gpxFile, .locations:
            gpxLocationManager.allowDeferredLocationUpdates(untilTraveled: distance, timeout: timeout)
        case .cLLocationManager:
            cLLocationManager.allowDeferredLocationUpdates(untilTraveled: distance, timeout: timeout)
        }
    }
    
    open func disallowDeferredLocationUpdates() {
        switch locationManagerType {
        case .gpxFile, .locations:
            gpxLocationManager.disallowDeferredLocationUpdates()
        case .cLLocationManager:
            cLLocationManager.disallowDeferredLocationUpdates()
        }
    }
    
    var monitoredRegions: Set<CLRegion> {
        get {
            switch locationManagerType {
            case .gpxFile, .locations:
                return gpxLocationManager.monitoredRegions
            case .cLLocationManager:
                return cLLocationManager.monitoredRegions
            }
        }
    }
    
    open func stopMonitoring(for region: CLRegion) {
        switch locationManagerType {
        case .gpxFile, .locations:
            gpxLocationManager.stopMonitoring(for: region)
        case .cLLocationManager:
            cLLocationManager.stopMonitoring(for: region)
        }
    }
    
    open func startMonitoring(for region: CLRegion) {
        switch locationManagerType {
        case .gpxFile, .locations:
            gpxLocationManager.startMonitoring(for: region)
        case .cLLocationManager:
            cLLocationManager.startMonitoring(for: region)
        }
    }
    
    open func startMonitoringSignificantLocationChanges() {
        switch locationManagerType {
        case .gpxFile, .locations:
            gpxLocationManager.startMonitoringSignificantLocationChanges()
        case .cLLocationManager:
            cLLocationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    open func startUpdatingLocation() {
        switch locationManagerType {
        case .gpxFile, .locations:
            gpxLocationManager.startUpdatingLocation()
        case .cLLocationManager:
            cLLocationManager.startUpdatingLocation()
        }
    }
}
