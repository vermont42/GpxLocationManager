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
    private static let overlayWidth: CGFloat = 3.0
    private static let regionSize: CLLocationDistance = 500.0
    private static let gpxTitle = "GPX File"
    private static let couldNotSaveMessage = "RaceRunner did not save this run because RaceRunner did not detect any locations using your device's GPS sensor."
    private static let bummerButtonTitle = "Bummer"
    private static let sadFaceTitle = "😢"
    private static let startTitle = " Start "
    private static let pauseTitle = " Pause "
    private static let stopTitle = " Stop "
    private static let resumeTitle = " Resume "
    private var runnerIcons = RunnerIcons()
    private var lastDirection: RunnerIcons.Direction = .Stationary
    var runToSimulate: Run?
    var gpxFile: String?
    
    override func viewDidLoad() {
        MKMapView.appearance().tintColor = UIColor.redColor()
        map.delegate = self
        showMenuButton.setImage(UiHelpers.maskedImageNamed("menu", color: UiConstants.lightColor), forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let runToSimulate = runToSimulate {
            RunModel.initializeRunModel(runToSimulate)
            if runToSimulate.customName.isEqualToString("") {
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
        case .PreRun:
            hideLabels()
            startStopButton.backgroundColor = UiConstants.intermediate3Color
            startStopButton.setTitle(RunVC.startTitle, forState: UIControlState.Normal)
            startStopButton.hidden = false
            pauseResume.hidden = true
        case .InProgress:
            showLabels()
            startStopButton.backgroundColor = UiConstants.intermediate1Color
            startStopButton.setTitle(RunVC.stopTitle, forState: UIControlState.Normal)
            pauseResume.hidden = false
            startStopButton.hidden = false
            pauseResume.setTitle(RunVC.pauseTitle, forState: UIControlState.Normal)
            addOverlays()
        case .Paused:
            showLabels()
            pauseResume.hidden = false
            startStopButton.hidden = false
            startStopButton.backgroundColor = UiConstants.intermediate1Color
            startStopButton.setTitle(RunVC.stopTitle, forState: UIControlState.Normal)
            pauseResume.setTitle(RunVC.resumeTitle, forState: UIControlState.Normal)
            addOverlays()
            let region = MKCoordinateRegionMakeWithDistance(currentCoordinate, RunVC.regionSize, RunVC.regionSize)
            map.setRegion(region, animated: true)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        RunModel.runModel.runDelegate = nil
    }
    
    func addOverlays() {
        let locations = RunModel.runModel.locations
        for var i = 0; i < locations.count - 1; i++ {
            var coords: [CLLocationCoordinate2D] = [locations[i].coordinate, locations[i + 1].coordinate]
            map.addOverlay(MKPolyline(coordinates: &coords, count: 2))
            
        }
        currentCoordinate = locations.last?.coordinate
        pin = MKPointAnnotation()
    }
    
    func showInitialCoordinate(coordinate: CLLocationCoordinate2D) {
        map.hidden = false
        let region = MKCoordinateRegionMakeWithDistance(coordinate, RunVC.regionSize, RunVC.regionSize)
        map.setRegion(region, animated: true)
        currentCoordinate = coordinate
        if pin == nil {
            pin = MKPointAnnotation()
        }
        map.addAnnotation(pin)
        pin.coordinate = coordinate
    }
    
    func plotToCoordinate(coordinate: CLLocationCoordinate2D) {
        if currentCoordinate != nil {
            if currentCoordinate.longitude > coordinate.longitude {
                runnerIcons.direction = .West
                lastDirection = .West
            }
            else if currentCoordinate.longitude < coordinate.longitude {
                runnerIcons.direction = .East
                lastDirection = .East
            }
            var coords: [CLLocationCoordinate2D] = [currentCoordinate, coordinate]
            let region = MKCoordinateRegionMakeWithDistance(coordinate, RunVC.regionSize, RunVC.regionSize)
            map.setRegion(region, animated: true)
            let overlay = MKPolyline(coordinates: &coords, count: 2)
            map.addOverlay(overlay)
            map.removeAnnotation(pin)
            pin.coordinate = coordinate
            map.addAnnotation(pin)
            currentCoordinate = coordinate
        }
        else {
            showInitialCoordinate(coordinate)
        }
    }
    
    func receiveProgress(distance: Double, time: Int) {
        timeLabel.text = "Time: \(Stringifier.stringifySecondCount(time, useLongFormat: true))"
        distanceLabel.text = "Distance: \(Stringifier.stringifyDistance(distance))"
        paceLabel.text = "Pace: \(Stringifier.stringifyAveragePaceFromDistance(distance, seconds: time))"
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.grayColor()
        renderer.lineWidth = RunVC.overlayWidth
        return renderer
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = map.dequeueReusableAnnotationViewWithIdentifier("Runner Pin View")
        if pinView == nil {
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Runner Pin View")
        }
        pinView!.image = runnerIcons.nextIcon()
        return pinView
    }
    
    @IBAction func showMenu(sender: UIButton) {
        if runToSimulate != nil || gpxFile != nil {
            RunModel.runModel.stop()
        }
        showMenu()
    }
    
    @IBAction func startStop() {
        switch RunModel.runModel.status {
        case .PreRun:
            showLabels()
            startStopButton.backgroundColor = UiConstants.intermediate1Color
            startStopButton.setTitle("  Stop  ", forState: UIControlState.Normal)
            pauseResume.hidden = false
            pauseResume.setTitle("  Pause  ", forState: UIControlState.Normal)
            RunModel.runModel.start()
        case .InProgress:
            stop()
        case .Paused:
            stop()
        }
    }
    
    func stop() {
        runnerIcons.direction = .Stationary
        startStopButton.backgroundColor = UiConstants.intermediate3Color
        startStopButton.setTitle("  Start  ", forState: UIControlState.Normal)
        pauseResume.hidden = true
        map.removeAnnotation(pin)
        RunModel.runModel.stop()
        if runToSimulate == nil && gpxFile == nil {
            if RunModel.runModel.run.locations.count > 0 {
                performSegueWithIdentifier("pan details from run", sender: self)
                for overlay in map.overlays {
                    map.removeOverlay(overlay )
                }
            }
            else {
                let alertController = UIAlertController(title: RunVC.sadFaceTitle, message: RunVC.couldNotSaveMessage, preferredStyle: .Alert)
                let bummerAction: UIAlertAction = UIAlertAction(title: RunVC.bummerButtonTitle, style: .Cancel) { action -> Void in
                    self.showMenu()
                }
                alertController.addAction(bummerAction)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
        else if runToSimulate != nil {
            self.performSegueWithIdentifier("unwind pan log", sender: self)
        }
        else { // if gpxFile != nil
            showMenu()
        }
    }
    
    @IBAction func pauseResume(sender: UIButton) {
        let runModel = RunModel.runModel
        switch runModel.status {
        case .PreRun:
            abort()
        case .InProgress:
            pauseResume.setTitle(RunVC.resumeTitle, forState: UIControlState.Normal)
            runModel.pause()
            runnerIcons.direction = .Stationary
            map.removeAnnotation(pin)
            map.addAnnotation(pin)
        case .Paused:
            pauseResume.setTitle(RunVC.pauseTitle, forState: UIControlState.Normal)
            runnerIcons.direction = lastDirection
            runModel.resume()
        }
        
    }
    
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue) {
        map.addAnnotation(pin)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "pan details from run" {
            let runDetailsVC: RunDetailsVC = segue.destinationViewController as! RunDetailsVC
            if runToSimulate == nil && gpxFile == nil {
                runDetailsVC.run = RunModel.runModel.run
                runDetailsVC.logType = .History
            }
        }
    }
    
    override func segueForUnwindingToViewController(toViewController: UIViewController, fromViewController: UIViewController, identifier: String?) -> UIStoryboardSegue {
        if let id = identifier{
            let unwindSegue = UnwindPanSegue(identifier: id, source: fromViewController, destination: toViewController, performHandler: { () -> Void in
            })
            return unwindSegue
        }
        
        return super.segueForUnwindingToViewController(toViewController, fromViewController: fromViewController, identifier: identifier)!
    }
    
    func hideLabels() {
        distanceLabel.hidden = true
        timeLabel.hidden = true
        paceLabel.hidden = true
    }
    
    func showLabels() {
        distanceLabel.hidden = false
        timeLabel.hidden = false
        paceLabel.hidden = false
    }
}