//
//  RunVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class RunVC: ChildVC, MKMapViewDelegate, RunDelegate {
    @IBOutlet var viewControllerTitle: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var paceLabel: UILabel!
    @IBOutlet var startStopButton: UIButton!
    @IBOutlet var showMenuButton: UIButton!
    @IBOutlet var pauseResume: UIButton!
    @IBOutlet var map: MKMapView!
    var currentCoordinate: CLLocationCoordinate2D!
    var pin: MKPointAnnotation!
    fileprivate static let overlayWidth: CGFloat = 3.0
    fileprivate static let regionSize: CLLocationDistance = 500.0
    fileprivate static let gpxTitle = "GPX File"
    fileprivate static let couldNotSaveMessage = "RaceRunner did not save this run because RaceRunner did not detect any locations using your device's GPS sensor."
    fileprivate static let bummerButtonTitle = "Bummer"
    fileprivate static let sadFaceTitle = "😢"
    fileprivate static let startTitle = " Start "
    fileprivate static let pauseTitle = " Pause "
    fileprivate static let stopTitle = " Stop "
    fileprivate static let resumeTitle = " Resume "
    fileprivate var runnerIcons = RunnerIcons()
    fileprivate var lastDirection: RunnerIcons.Direction = .stationary
    var runToSimulate: Run?
    var gpxFile: String?
    
    override func viewDidLoad() {
        MKMapView.appearance().tintColor = UIColor.red
        map.delegate = self
        showMenuButton.setImage(UiHelpers.maskedImageNamed("menu", color: UiConstants.lightColor), for: UIControlState())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let runToSimulate = runToSimulate {
            RunModel.initializeRunModel(runToSimulate)
            if runToSimulate.customName.isEqual(to: "") {
                viewControllerTitle.text = runToSimulate.autoName as String
            }
            else {
                viewControllerTitle.text = runToSimulate.customName as String
            }
            startStop()
        }
        else if let gpxFile = gpxFile {
            RunModel.initializeRunModelWithGpxFile(gpxFile)
            viewControllerTitle.text = RunVC.gpxTitle
            startStop()
        }
        else {
            RunModel.initializeRunModel()
            viewControllerTitle.text = "Run"
        }
        viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
        
        let runModel = RunModel.runModel
        runModel.runDelegate = self
        switch runModel.status {
        case .preRun:
            hideLabels()
            startStopButton.backgroundColor = UiConstants.intermediate3Color
            startStopButton.setTitle(RunVC.startTitle, for: UIControlState())
            startStopButton.isHidden = false
            pauseResume.isHidden = true
        case .inProgress:
            showLabels()
            startStopButton.backgroundColor = UiConstants.intermediate1Color
            startStopButton.setTitle(RunVC.stopTitle, for: UIControlState())
            pauseResume.isHidden = false
            startStopButton.isHidden = false
            pauseResume.setTitle(RunVC.pauseTitle, for: UIControlState())
            addOverlays()
        case .paused:
            showLabels()
            pauseResume.isHidden = false
            startStopButton.isHidden = false
            startStopButton.backgroundColor = UiConstants.intermediate1Color
            startStopButton.setTitle(RunVC.stopTitle, for: UIControlState())
            pauseResume.setTitle(RunVC.resumeTitle, for: UIControlState())
            addOverlays()
            let region = MKCoordinateRegionMakeWithDistance(currentCoordinate, RunVC.regionSize, RunVC.regionSize)
            map.setRegion(region, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        RunModel.runModel.runDelegate = nil
    }
    
    func addOverlays() {
        let locations = RunModel.runModel.locations
        if let locations = locations, locations.count > 2 {
            for i in 0 ..< locations.count - 1 {
                var coords: [CLLocationCoordinate2D] = [locations[i].coordinate, locations[i + 1].coordinate]
                map.add(MKPolyline(coordinates: &coords, count: 2))
                
            }
            currentCoordinate = locations.last?.coordinate
            pin = MKPointAnnotation()
        }
    }
    
    func showInitialCoordinate(_ coordinate: CLLocationCoordinate2D) {
        map.isHidden = false
        let region = MKCoordinateRegionMakeWithDistance(coordinate, RunVC.regionSize, RunVC.regionSize)
        map.setRegion(region, animated: true)
        currentCoordinate = coordinate
        if pin == nil {
            pin = MKPointAnnotation()
        }
        map.addAnnotation(pin)
        pin.coordinate = coordinate
    }
    
    func plotToCoordinate(_ coordinate: CLLocationCoordinate2D) {
        if currentCoordinate != nil {
            if currentCoordinate.longitude > coordinate.longitude {
                runnerIcons.direction = .west
                lastDirection = .west
            }
            else if currentCoordinate.longitude < coordinate.longitude {
                runnerIcons.direction = .east
                lastDirection = .east
            }
            var coords: [CLLocationCoordinate2D] = [currentCoordinate, coordinate]
            let region = MKCoordinateRegionMakeWithDistance(coordinate, RunVC.regionSize, RunVC.regionSize)
            map.setRegion(region, animated: true)
            let overlay = MKPolyline(coordinates: &coords, count: 2)
            map.add(overlay)
            map.removeAnnotation(pin)
            pin.coordinate = coordinate
            map.addAnnotation(pin)
            currentCoordinate = coordinate
        }
        else {
            showInitialCoordinate(coordinate)
        }
    }
    
    func receiveProgress(_ distance: Double, time: Int) {
        timeLabel.text = "Time: \(Stringifier.stringifySecondCount(time, useLongFormat: true))"
        distanceLabel.text = "Distance: \(Stringifier.stringifyDistance(distance))"
        paceLabel.text = "Pace: \(Stringifier.stringifyAveragePaceFromDistance(distance, seconds: time))"
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.gray
        renderer.lineWidth = RunVC.overlayWidth
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = map.dequeueReusableAnnotationView(withIdentifier: "Runner Pin View")
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Runner Pin View")
        }
        pinView!.image = runnerIcons.nextIcon()
        return pinView
    }
    
    @IBAction func showMenu(_ sender: UIButton) {
        if runToSimulate != nil || gpxFile != nil {
            RunModel.runModel.stop()
        }
        showMenu()
    }
    
    @IBAction func startStop() {
        switch RunModel.runModel.status {
        case .preRun:
            showLabels()
            startStopButton.backgroundColor = UiConstants.intermediate1Color
            startStopButton.setTitle("  Stop  ", for: UIControlState())
            pauseResume.isHidden = false
            pauseResume.setTitle("  Pause  ", for: UIControlState())
            RunModel.runModel.start()
        case .inProgress:
            stop()
        case .paused:
            stop()
        }
    }
    
    func stop() {
        runnerIcons.direction = .stationary
        startStopButton.backgroundColor = UiConstants.intermediate3Color
        startStopButton.setTitle("  Start  ", for: UIControlState())
        pauseResume.isHidden = true
        map.removeAnnotation(pin)
        RunModel.runModel.stop()
        if runToSimulate == nil && gpxFile == nil {
            if RunModel.runModel.run.locations.count > 0 {
                performSegue(withIdentifier: "pan details from run", sender: self)
                for overlay in map.overlays {
                    map.remove(overlay )
                }
            }
            else {
                let alertController = UIAlertController(title: RunVC.sadFaceTitle, message: RunVC.couldNotSaveMessage, preferredStyle: .alert)
                let bummerAction: UIAlertAction = UIAlertAction(title: RunVC.bummerButtonTitle, style: .cancel) { action -> Void in
                    self.showMenu()
                }
                alertController.addAction(bummerAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        else if runToSimulate != nil {
            self.performSegue(withIdentifier: "unwind pan log", sender: self)
        }
        else { // if gpxFile != nil
            showMenu()
        }
    }
    
    @IBAction func pauseResume(_ sender: UIButton) {
        let runModel = RunModel.runModel
        switch runModel.status {
        case .preRun:
            abort()
        case .inProgress:
            pauseResume.setTitle(RunVC.resumeTitle, for: UIControlState())
            runModel.pause()
            runnerIcons.direction = .stationary
            map.removeAnnotation(pin)
            map.addAnnotation(pin)
        case .paused:
            pauseResume.setTitle(RunVC.pauseTitle, for: UIControlState())
            runnerIcons.direction = lastDirection
            runModel.resume()
        }
        
    }
    
    @IBAction func returnFromSegueActions(_ sender: UIStoryboardSegue) {
        map.addAnnotation(pin)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pan details from run" {
            let runDetailsVC: RunDetailsVC = segue.destination as! RunDetailsVC
            if runToSimulate == nil && gpxFile == nil {
                runDetailsVC.run = RunModel.runModel.run
                runDetailsVC.logType = .history
            }
        }
    }
    
    override func segueForUnwinding(to toViewController: UIViewController, from fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        if let id = identifier{
            let unwindSegue = UnwindPanSegue(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
            })
            return unwindSegue
        }
        
        return super.segueForUnwinding(to: toViewController, from: fromViewController, identifier: identifier)!
    }
    
    func hideLabels() {
        distanceLabel.isHidden = true
        timeLabel.isHidden = true
        paceLabel.isHidden = true
    }
    
    func showLabels() {
        distanceLabel.isHidden = false
        timeLabel.isHidden = false
        paceLabel.isHidden = false
    }
}
