//
//  LocationManager.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 4/23/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import CoreLocation

public class LocationManager {
    private var gpxLocationManager: GpxLocationManager!
    private var cLLocationManager: CLLocationManager!
    public enum LocationManagerType {
        case Gpx, CoreLocation
        init() {
            self = .CoreLocation
        }
    }
    public var location: CLLocation! {
        get {
            switch locationManagerType {
            case .Gpx:
                return gpxLocationManager.location
            case .CoreLocation:
                return cLLocationManager.location
            }
        }
    }
    public weak var delegate: CLLocationManagerDelegate! {
        get {
            switch locationManagerType {
            case .Gpx:
                return gpxLocationManager.delegate
            case .CoreLocation:
                return cLLocationManager.delegate
            }
        }
        set {
            switch locationManagerType {
            case .Gpx:
                gpxLocationManager.delegate = newValue
            case .CoreLocation:
                cLLocationManager.delegate = newValue
            }
        }
    }
    public var desiredAccuracy: CLLocationAccuracy {
        get {
            switch locationManagerType {
            case .Gpx:
                return gpxLocationManager.desiredAccuracy
            case .CoreLocation:
                return cLLocationManager.desiredAccuracy
            }
        }
        set {
            switch locationManagerType {
            case .Gpx:
                gpxLocationManager.desiredAccuracy = newValue
            case .CoreLocation:
                cLLocationManager.desiredAccuracy = newValue
            }
        }
    }
    public var activityType: CLActivityType {
        get {
            switch locationManagerType {
            case .Gpx:
                return gpxLocationManager.activityType
            case .CoreLocation:
                return cLLocationManager.activityType
            }
        }
        set {
            switch locationManagerType {
            case .Gpx:
                gpxLocationManager.activityType = newValue
            case .CoreLocation:
                cLLocationManager.activityType = newValue
            }
        }
    }
    public var distanceFilter: CLLocationDistance {
        get {
            switch locationManagerType {
            case .Gpx:
                return gpxLocationManager.distanceFilter
            case .CoreLocation:
                return cLLocationManager.distanceFilter
            }
        }
        set {
            switch locationManagerType {
            case .Gpx:
                gpxLocationManager.distanceFilter = newValue
            case .CoreLocation:
                cLLocationManager.distanceFilter = newValue
            }
        }
    }
    public var pausesLocationUpdatesAutomatically: Bool {
        get {
            switch locationManagerType {
            case .Gpx:
                return gpxLocationManager.pausesLocationUpdatesAutomatically
            case .CoreLocation:
                return cLLocationManager.pausesLocationUpdatesAutomatically
            }
        }
        set {
            switch locationManagerType {
            case .Gpx:
                gpxLocationManager.pausesLocationUpdatesAutomatically = newValue
            case .CoreLocation:
                cLLocationManager.pausesLocationUpdatesAutomatically = newValue
            }
        }
    }
    public func requestAlwaysAuthorization() {
        switch locationManagerType {
        case .Gpx:
            gpxLocationManager.requestAlwaysAuthorization()
        case .CoreLocation:
            cLLocationManager.requestAlwaysAuthorization()
        }
    }
    public var secondLength: Double {
        get {
            switch locationManagerType {
            case .Gpx:
                return gpxLocationManager.secondLength
            case .CoreLocation:
                return 1.0
            }
        }
        set {
            switch locationManagerType {
            case .Gpx:
                gpxLocationManager.secondLength = newValue
            case .CoreLocation:
                break
            }
        }
    }
    public func kill() {
        switch locationManagerType {
        case .Gpx:
            gpxLocationManager.kill()
        case .CoreLocation:
            break
        }
    }

    public let locationManagerType: LocationManagerType
    
    public init() {
        cLLocationManager = CLLocationManager()
        locationManagerType = .CoreLocation
    }
    
    public init(gpxFile: String) {
        gpxLocationManager = GpxLocationManager(gpxFile: gpxFile)
        locationManagerType = .Gpx
    }
    
    public init(locations: [CLLocation]) {
        gpxLocationManager = GpxLocationManager(locations: locations)
        locationManagerType = .Gpx
    }
    
    public func stopUpdatingLocation() {
        switch locationManagerType {
        case .Gpx:
            gpxLocationManager.stopUpdatingLocation()
        case .CoreLocation:
            cLLocationManager.stopUpdatingLocation()
        }
    }
    
    public func startUpdatingLocation() {
        switch locationManagerType {
        case .Gpx:
            gpxLocationManager.startUpdatingLocation()
        case .CoreLocation:
            cLLocationManager.startUpdatingLocation()
        }
    }
    
}