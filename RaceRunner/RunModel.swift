//
//  RunModel.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/13/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import CoreData
//import AVFoundation   // necessary for utterances

protocol RunDelegate {
    func showInitialCoordinate(coordinate: CLLocationCoordinate2D)
    func plotToCoordinate(coordinate: CLLocationCoordinate2D)
    func receiveProgress(distance: Double, time: Int)
}

class RunModel: NSObject, CLLocationManagerDelegate {
    var distance = 0.0
    var seconds = 0
    var temperature: Float = 0.0
    var weather = ""
    var timer: NSTimer!
    var locations: [CLLocation]! = []
    var initialLocation: CLLocation!
    var locationManager: LocationManager!
    var status : Status = .PreRun
    var runDelegate: RunDelegate?
    var autoName = RunModel.noStreetNameDetected
    var didSetAutoNameAndFirstLoc = false
    var altGained  = 0.0
    var altLost = 0.0
    var minLong = 0.0
    var maxLong = 0.0
    var minLat = 0.0
    var maxLat = 0.0
    var minAlt = 0.0
    var maxAlt = 0.0
    var curAlt = 0.0
    var runToSimulate: Run!
    var gpxFile: String!
    var run: Run!
    var realRunInProgress = false
    private var secondLength = 1.0
    static let altFudge: Double = 0.1
    private static let distanceTolerance: Double = 0.05
    private static let coordinateTolerance: Double = 0.0000050
    private static let unknownRoute: String = "unknown route"
    private static let minAccuracy: CLLocationDistance = 20.0
    private static let distanceFilter: CLLocationDistance = 10.0
    private static let freezeDriedAccuracy: CLLocationAccuracy = 5.0
    static let noStreetNameDetected: String = "no street name detected"
    private static let defaultTemperature: Float = 25.0
    private static let defaultWeather = "sunny"
    
    enum Status {
        case PreRun
        case InProgress
        case Paused
    }
    
    static let runModel = RunModel()
    
    // For reasons unclear to me, SourceKit did not allow this function to
    // have the following signature, which I would have preferred:
    // class func initializeRunModel(gpxFile: String)
    class func initializeRunModelWithGpxFile(gpxFile: String) {
        runModel.gpxFile = gpxFile
        runModel.runToSimulate = nil
        runModel.locationManager = LocationManager(gpxFile: gpxFile)
        finishSimulatorSetup()
    }
    
    class func initializeRunModel(runToSimulate: Run) {
        runModel.runToSimulate = runToSimulate
        runModel.gpxFile = nil
        var cLLocations: [CLLocation] = []
        for uncastedLocation in runToSimulate.locations {
            let location = uncastedLocation as! Location
            cLLocations.append(CLLocation(coordinate: CLLocationCoordinate2D(latitude: location.latitude.doubleValue, longitude: location.longitude.doubleValue), altitude: location.altitude.doubleValue, horizontalAccuracy: RunModel.freezeDriedAccuracy, verticalAccuracy: RunModel.freezeDriedAccuracy, timestamp: location.timestamp))
        }
        runModel.locationManager = LocationManager(locations: cLLocations)
        finishSimulatorSetup()
    }
    
    class func finishSimulatorSetup() {
        runModel.secondLength /= SettingsManager.getMultiplier()
        runModel.locationManager.secondLength = runModel.secondLength
        runModel.status = .PreRun
        configureLocationManager()
        runModel.locationManager.startUpdatingLocation()
    }
    
    class func initializeRunModel() {
        runModel.runToSimulate = nil
        runModel.gpxFile = nil
        runModel.secondLength = 1.0
        if runModel.locationManager == nil {
            runModel.locationManager = LocationManager()
            configureLocationManager()
        }
        runModel.locationManager.startUpdatingLocation()
    }
    
    class func configureLocationManager() {
        runModel.locationManager.delegate = runModel
        runModel.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        runModel.locationManager.activityType = .Fitness
        runModel.locationManager.requestAlwaysAuthorization()
        runModel.locationManager.distanceFilter = RunModel.distanceFilter
        runModel.locationManager.pausesLocationUpdatesAutomatically = false
        runModel.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        switch status {
        case .PreRun:
            initialLocation = locations[0] 
            runDelegate?.showInitialCoordinate(initialLocation.coordinate)
            locationManager.stopUpdatingLocation()
            if runToSimulate == nil && gpxFile == nil {
                DarkSky().currentWeather(CLLocationCoordinate2D(
                    latitude: initialLocation.coordinate.latitude,
                    longitude: initialLocation.coordinate.longitude) ) { result in
                        switch result {
                        case .Error(_, _):
                            self.temperature = DarkSky.temperatureError
                            self.weather = DarkSky.weatherError
                        case .Success(_, let dictionary):
                            if dictionary != nil {
                                self.temperature = Stringifier.convertFahrenheitToCelsius(dictionary["currently"]!["apparentTemperature"] as! Float)
                                self.weather = dictionary["currently"]!["summary"] as! String
                                //let synth = AVSpeechSynthesizer()
                                //var utterance = AVSpeechUtterance(string: self.weather)
                                //utterance.rate = 0.3
                                //synth.speakUtterance(utterance)
                            }
                            else {
                                self.temperature = DarkSky.temperatureError
                                self.weather = DarkSky.weatherError                                
                            }
                        }
                }
            }
        case .InProgress:
            for location in locations {
                let newLocation: CLLocation = location 
                if abs(newLocation.horizontalAccuracy) < RunModel.minAccuracy {
                    if self.locations.count > 0 {
                        distance += newLocation.distanceFromLocation(self.locations.last!)
                        runDelegate?.plotToCoordinate(newLocation.coordinate)
                    }
                    else {
                        runDelegate?.showInitialCoordinate(newLocation.coordinate)
                    }
                    self.locations.append(newLocation)
                }
                
                if !didSetAutoNameAndFirstLoc {
                    didSetAutoNameAndFirstLoc = true
                    if runToSimulate == nil && gpxFile == nil {
                        CLGeocoder().reverseGeocodeLocation(newLocation, completionHandler:
                            {(placemarks, error) in
                                if error == nil {
                                    if placemarks?.count > 0 {
                                        let placemark = placemarks![0]
                                        if let thoroughfare = placemark.thoroughfare {
                                            self.autoName = thoroughfare
                                        }
                                    }
                                    else {
                                        self.autoName = RunModel.unknownRoute
                                    }
                                }
                                else {
                                    self.autoName = RunModel.unknownRoute
                                }
                        })
                    }
                    minAlt = newLocation.altitude
                    maxAlt = newLocation.altitude
                    minLong = newLocation.coordinate.longitude
                    maxLong = newLocation.coordinate.longitude
                    minLat = newLocation.coordinate.latitude
                    maxLat = newLocation.coordinate.latitude
                }
                else {
                    if newLocation.coordinate.latitude < minLat {
                        minLat = newLocation.coordinate.latitude
                    }
                    if newLocation.coordinate.longitude < minLong {
                        minLong = newLocation.coordinate.longitude
                    }
                    if newLocation.coordinate.latitude > maxLat {
                        maxLat = newLocation.coordinate.latitude
                    }
                    if newLocation.coordinate.longitude > maxLong {
                        maxLong = newLocation.coordinate.longitude
                    }
                    if newLocation.altitude < minAlt {
                        minAlt = newLocation.altitude
                    }
                    if newLocation.altitude > maxAlt {
                        maxAlt = newLocation.altitude
                    }
                    if newLocation.altitude > curAlt + RunModel.altFudge {
                        altGained += newLocation.altitude - curAlt
                    }
                    if newLocation.altitude < curAlt - RunModel.altFudge {
                        altLost += curAlt - newLocation.altitude
                    }
                }
                curAlt = newLocation.altitude
            }
        case .Paused:
            abort()
        }
    }
    
    func eachSecond() {
        seconds++
        runDelegate?.receiveProgress(distance, time: seconds)
    }
    
    func start() {
        status = .InProgress
        locationManager.startUpdatingLocation()
        startTimer()
        if runToSimulate == nil && gpxFile == nil {
            realRunInProgress = true
        }
    }
    
    private class func addRun(coordinates: [CLLocation], customName: String, autoName: String, timestamp: NSDate, weather: String, temperature: Float, distance: Double, maxAltitude: Double, minAltitude: Double, maxLongitude: Double, minLongitude: Double, maxLatitude: Double, minLatitude: Double, altitudeGained: Double, altitudeLost: Double) -> Run {
        let newRun: Run = NSEntityDescription.insertNewObjectForEntityForName("Run", inManagedObjectContext: CDManager.sharedCDManager.context) as! Run
        newRun.distance = distance
        newRun.duration = coordinates[coordinates.count - 1].timestamp.timeIntervalSinceDate(coordinates[0].timestamp)
        newRun.timestamp = timestamp
        newRun.weather = weather
        newRun.temperature = temperature
        newRun.customName = customName
        newRun.autoName = autoName
        newRun.maxAltitude = maxAltitude
        newRun.minAltitude = minAltitude
        newRun.maxLatitude = maxLatitude
        newRun.minLatitude = minLatitude
        newRun.maxLongitude = maxLongitude
        newRun.minLongitude = minLongitude
        newRun.altitudeGained = altitudeGained
        newRun.altitudeLost = altitudeLost
        var locationArray: [Location] = []
        for location in coordinates {
            let locationObject: Location = NSEntityDescription.insertNewObjectForEntityForName("Location", inManagedObjectContext: CDManager.sharedCDManager.context) as! Location
            locationObject.timestamp = location.timestamp
            locationObject.latitude = location.coordinate.latitude
            locationObject.longitude = location.coordinate.longitude
            locationObject.altitude = location.altitude
            locationArray.append(locationObject)
        }
        newRun.locations = NSOrderedSet(array: locationArray)
        CDManager.saveContext()
        return newRun
    }
    
    class func addRun(coordinates: [CLLocation], customName: String, timestamp: NSDate) -> Run {
        var distance = 0.0
        var altGained  = 0.0
        var altLost = 0.0
        var minLong = coordinates[0].coordinate.longitude
        var maxLong = coordinates[0].coordinate.longitude
        var minLat = coordinates[0].coordinate.latitude
        var maxLat = coordinates[0].coordinate.latitude
        var minAlt = coordinates[0].altitude
        var maxAlt = coordinates[0].altitude
        var curAlt = coordinates[0].altitude
        var currentCoordinate = coordinates[0]
        for var i = 1; i < coordinates.count; i++ {
            distance += coordinates[i].distanceFromLocation(currentCoordinate)
            currentCoordinate = coordinates[i]
            if currentCoordinate.coordinate.latitude < minLat {
                minLat = currentCoordinate.coordinate.latitude
            }
            if currentCoordinate.coordinate.longitude < minLong {
                minLong = currentCoordinate.coordinate.longitude
            }
            if currentCoordinate.coordinate.latitude > maxLat {
                maxLat = currentCoordinate.coordinate.latitude
            }
            if currentCoordinate.coordinate.longitude > maxLong {
                maxLong = currentCoordinate.coordinate.longitude
            }
            if currentCoordinate.altitude < minAlt {
                minAlt = currentCoordinate.altitude
            }
            if currentCoordinate.altitude > maxAlt {
                maxAlt = currentCoordinate.altitude
            }
            if currentCoordinate.altitude > curAlt + RunModel.altFudge {
                altGained += currentCoordinate.altitude - curAlt
            }
            if currentCoordinate.altitude < curAlt - RunModel.altFudge {
                altLost += curAlt - currentCoordinate.altitude
            }
            curAlt = coordinates[i].altitude
        }
        return RunModel.addRun(coordinates, customName: customName, autoName: customName, timestamp: timestamp, weather: RunModel.defaultWeather, temperature: RunModel.defaultTemperature, distance: distance, maxAltitude: maxAlt, minAltitude: minAlt, maxLongitude: maxLong, minLongitude: minLong, maxLatitude: maxLat, minLatitude: minLat, altitudeGained: altGained, altitudeLost: altLost)
    }
    
    func stop() {
        timer.invalidate()
        locationManager.stopUpdatingLocation()
        if runToSimulate == nil && gpxFile == nil {
            realRunInProgress = false
            var customName = ""
            let fetchRequest = NSFetchRequest()
            let context = CDManager.sharedCDManager.context
            fetchRequest.entity = NSEntityDescription.entityForName("Run", inManagedObjectContext: context)
            let pastRuns = (try! context.executeFetchRequest(fetchRequest)) as! [Run]
            for pastRun in pastRuns {
                if pastRun.customName != "" {
                    if (!RunModel.matchMeasurement(pastRun.distance.doubleValue, measurement2: distance, tolerance: RunModel.distanceTolerance)) ||
                        (!RunModel.matchMeasurement(pastRun.maxLatitude.doubleValue, measurement2: maxLat, tolerance: RunModel.coordinateTolerance)) ||
                        (!RunModel.matchMeasurement(pastRun.minLatitude.doubleValue, measurement2: minLat, tolerance: RunModel.coordinateTolerance)) ||
                        (!RunModel.matchMeasurement(pastRun.maxLongitude.doubleValue, measurement2: maxLong, tolerance: RunModel.coordinateTolerance)) ||
                        (!RunModel.matchMeasurement(pastRun.minLongitude.doubleValue, measurement2: minLong, tolerance: RunModel.coordinateTolerance)) {
                            continue
                    }
                    customName = pastRun.customName as String
                    break
                }
            }
            run = RunModel.addRun(locations, customName: customName, autoName: autoName, timestamp: NSDate(), weather: weather, temperature: temperature, distance: distance, maxAltitude: maxAlt, minAltitude: minAlt, maxLongitude: maxLong, minLongitude: minLong, maxLatitude: maxLat, minLatitude: minLat, altitudeGained: altGained, altitudeLost: altLost)
        }
        else {
            // I don't consider this a magic number because the unadjusted length of a second will never change.
            secondLength = 1.0
            locationManager.kill()
            locationManager = nil
        }
        seconds = 0
        distance = 0.0
        status = .PreRun
        locations = []
        didSetAutoNameAndFirstLoc = false
        altGained  = 0.0
        altLost = 0.0
        minLong = 0.0
        maxLong = 0.0
        minLat = 0.0
        maxLat = 0.0
        minAlt = 0.0
        maxAlt = 0.0
    }
    
    func pause() {
        status = .Paused
        timer.invalidate()
        locationManager.stopUpdatingLocation()
    }
    
    func resume() {
        status = .InProgress
        locationManager.startUpdatingLocation()
        startTimer()
    }
    
    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(secondLength, target: self, selector: Selector("eachSecond"), userInfo: nil, repeats: true)
    }
    
    class func matchMeasurement(measurement1: Double, measurement2: Double, tolerance: Double) -> Bool {
        let diff = fabs(measurement2 - measurement1)
        if (diff / measurement2) > tolerance {
            return false
        }
        else {
            return true
        }
    }
}


