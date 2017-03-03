//
//  RunDetailsVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/8/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit
import MapKit

class RunDetailsVC: UIViewController, MKMapViewDelegate, UIAlertViewDelegate, UITextFieldDelegate {
    @IBOutlet var map: MKMapView!
    @IBOutlet var date: UILabel!
    @IBOutlet var distance: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var pace: UILabel!
    @IBOutlet var minAlt: UILabel!
    @IBOutlet var maxAlt: UILabel!
    @IBOutlet var gain: UILabel!
    @IBOutlet var loss: UILabel!
    @IBOutlet var temp: UILabel!
    @IBOutlet var weather: UILabel!
    @IBOutlet var paceOrAltitude: UISegmentedControl!
    @IBOutlet var route: MarqueeLabel!
    @IBOutlet var customTitleButton: UIButton!
    
    var alertView: UIAlertView!
    var colorPaceSegments: [MulticolorPolyline] = []
    var colorAltitudeSegments: [MulticolorPolyline] = []
    var run: Run!
    var logType: LogVC.LogType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        if self.run.locations.count > 0 {
            configureView()
        }
        else {
            abort() // No need for graceful error handling because no run without locations is ever saved or displayed.
        }
        customTitleButton.setImage(UiHelpers.maskedImageNamed("edit", color: UiConstants.intermediate2Color), for: UIControlState())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func configureView() {
        var region = MKCoordinateRegion()
        region.center.latitude = CLLocationDegrees((run.minLatitude.doubleValue + run.maxLatitude.doubleValue) / 2.0)
        region.center.longitude = CLLocationDegrees((run.minLongitude.doubleValue + run.maxLongitude.doubleValue) / 2.0)
        region.span.latitudeDelta = Double(run.maxLatitude.doubleValue - run.minLatitude.doubleValue) * 2.1
        region.span.longitudeDelta = Double(run.maxLongitude.doubleValue - run.minLongitude.doubleValue) * 2.1
        map.setRegion(region, animated: true)
        addOverlays()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        date.text = dateFormatter.string(from: run.timestamp as Date)
        distance.text = "Dist: \(Stringifier.stringifyDistance(run.distance.doubleValue))"
        time.text = "Time: \(Stringifier.stringifySecondCount(run.duration.intValue, useLongFormat: false))"
        pace.text = "Pace: \(Stringifier.stringifyAveragePaceFromDistance(run.distance.doubleValue, seconds: run.duration.intValue))"
        self.minAlt.text = "Min Alt: \(Stringifier.stringifyAltitude(run.minAltitude.doubleValue))"
        self.maxAlt.text = "Max Alt: \(Stringifier.stringifyAltitude(run.maxAltitude.doubleValue))"
        self.gain.text = "Gained: \(Stringifier.stringifyAltitude(run.altitudeGained.doubleValue))"
        self.loss.text = "Lost: \(Stringifier.stringifyAltitude(run.altitudeLost.doubleValue))"
        if run.weather as String == DarkSky.weatherError {
            self.weather.text = "Unknown Weather"
        }
        else {
            self.weather.text = "Weather: \(run.weather as String)"
        }
        if run.temperature.floatValue == DarkSky.temperatureError {
            self.temp.text = "Unknown Temp"
        }
        else {
            self.temp.text = "Temp: \(Stringifier.stringifyTemperature(run.temperature.floatValue))"
        }
        if run.customName == "" {
            if self.run.autoName as String == RunModel.noStreetNameDetected {
                self.route.text = "Unnamed Route"
            }
            else {
                self.route.text = "Name: \(run.autoName as String)"
            }
        }
        else {
            self.route.text = "Name: \(run.customName as String)"
        }
    }

    func addOverlays() {
        if run.locations.count > 1 {
            if (paceOrAltitude.selectedSegmentIndex == 0 && colorPaceSegments.count == 0) ||
                (paceOrAltitude.selectedSegmentIndex == 1 && colorAltitudeSegments.count == 0) {
                var rawValues: [Double] = []
                if paceOrAltitude.selectedSegmentIndex == 0 {
                    for i in 1 ..< run.locations.count {
                        let firstLoc = run.locations[i - 1] as! Location
                        let secondLoc = run.locations[i] as! Location
                        let firstLocCL = CLLocation(latitude: firstLoc.latitude.doubleValue, longitude: firstLoc.longitude.doubleValue)
                        let secondLocCL = CLLocation(latitude: secondLoc.latitude.doubleValue, longitude: secondLoc.longitude.doubleValue)
                        let distance = secondLocCL.distance(from: firstLocCL)
                        let time = secondLoc.timestamp.timeIntervalSince(firstLoc.timestamp as Date)
                        let speed = distance / time
                        rawValues.append(speed)
                    }
                }
                else {
                    for i in 0 ..< run.locations.count {
                        let location = run.locations[i] as! Location
                        rawValues.append(location.altitude.doubleValue)
                    }
                }
                let idealSmoothReachSize = 33 // about 133 locations/mile
                var smoothValues: [Double] = []
                for (i, _) in rawValues.enumerated() {
                    var lowerBound = i - idealSmoothReachSize / 2
                    var upperBound = i + idealSmoothReachSize / 2
                    if lowerBound < 0 {
                        lowerBound = 0;
                    }
                    if upperBound > (rawValues.count - 1) {
                        upperBound = rawValues.count - 1
                    }
                    var range = NSRange()
                    range.location = lowerBound
                    range.length = upperBound - lowerBound
                    let indexSet = NSIndexSet(indexesIn: range)
                    var relevantValues: [Double] = []
                    for index in indexSet {
                        relevantValues.append(rawValues[index])
                    }
                    var total = 0.0
                    for value in relevantValues {
                        total += value
                    }
                    let smoothAverage = total / Double(upperBound - lowerBound)
                    smoothValues.append(smoothAverage)
                }
                var sortedValues = smoothValues
                sortedValues.sort { $0 < $1 }
                let medianValue = sortedValues[run.locations.count / 2]
                let r_red: CGFloat = 1.0
                let r_green: CGFloat = 20.0 / 255.0
                let r_blue: CGFloat = 44.0 / 255.0
                let y_red: CGFloat = 1.0
                let y_green: CGFloat = 215.0 / 255.0
                let y_blue: CGFloat = 0.0
                let g_red: CGFloat = 0.0
                let g_green: CGFloat = 146.0 / 255.0
                let g_blue: CGFloat = 78.0 / 255.0
                var colorSegments: [MulticolorPolyline] = []
                for i in 1 ..< run.locations.count {
                    let firstLoc = run.locations[i - 1] as! Location
                    let secondLoc = run.locations[i] as! Location
                    let firstLocCL = CLLocation(latitude: firstLoc.latitude.doubleValue, longitude: firstLoc.longitude.doubleValue)
                    let secondLocCL = CLLocation(latitude: secondLoc.latitude.doubleValue, longitude: secondLoc.longitude.doubleValue)
                    var coords = [firstLocCL.coordinate, secondLocCL.coordinate]
                    let value = smoothValues[i - 1]
                    var color: UIColor
                    var index = sortedValues.index(of: value)
                    if (index == nil) {
                        index = 0
                    }
                    if value < medianValue {
                        let ratio = CGFloat(index!) / (CGFloat(run.locations.count) / 2.0)
                        let red = r_red + ratio * (y_red - r_red)
                        let green = r_green + ratio * (y_green - r_green)
                        let blue = r_blue + ratio * (y_blue - r_blue)
                        color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
                    }
                    else {
                        let ratio = (CGFloat(index!) - CGFloat(run.locations.count / 2)) / CGFloat(run.locations.count / 2)
                        let red = y_red + ratio * (g_red - y_red)
                        let green = y_green + ratio * (g_green - y_green)
                        let blue = y_blue + ratio * (g_blue - y_blue)
                        color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
                    }
                    let segment = MulticolorPolyline(coordinates: &coords, count: 2)
                    segment.color = color
                    colorSegments.append(segment)
                }
                map.addOverlays(colorSegments)
                if paceOrAltitude.selectedSegmentIndex == 0 {
                    colorPaceSegments = colorSegments
                }
                else {
                    colorAltitudeSegments = colorSegments
                }
            }
            else {
                map.addOverlays(paceOrAltitude.selectedSegmentIndex == 0 ? colorPaceSegments: colorAltitudeSegments)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyLine = overlay as! MulticolorPolyline
        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.strokeColor = polyLine.color
        renderer.lineWidth = 3
        return renderer;
    }
    
    @IBAction func setCustomName() {        
        let alertController = UIAlertController(title: "Run Name", message: "Enter a new name for this run.", preferredStyle: UIAlertControllerStyle.alert)
        
        let setAction = UIAlertAction(title: "Set", style: UIAlertActionStyle.default, handler: { (action) in
            let textFields = alertController.textFields!
            self.route.text = "Name: \(textFields[0].text!)"
            self.run.customName = textFields[0].text! as NSString
            CDManager.saveContext()
        })
        alertController.addAction(setAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in })
        alertController.addAction(cancelAction)
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func changeOverlay(_ sender: UISegmentedControl) {
        addOverlays()
    }
    
    @IBAction func back(_ sender: UIButton) {
        if logType == LogVC.LogType.history {
            self.performSegue(withIdentifier: "unwind pan log", sender: self)
        }
        else if logType == LogVC.LogType.simulate {
            self.performSegue(withIdentifier: "unwind pan", sender: self)
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
