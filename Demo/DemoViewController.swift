//
//  DemoViewController.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 4/11/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import MapKit
import CoreLocation
import GpxLocationManager

enum DemoType {
  case gpx
  case locations
  case coreLocation

  static func from(_ index: Int) -> DemoType? {
    switch index {
    case 0: return .gpx
    case 1: return .locations
    case 2: return .coreLocation
    default: return nil
    }
  }
}

class DemoViewController: UIViewController, CLLocationManagerDelegate {
  private let gpxFile1 = "Berkeley"
  private let gpxFile2 = "Orinda"
  private var locations: [CLLocation] = []
  private let minSpeed = 1.0
  private let maxSpeed = 10.0
  private var currentSpeed = 10.0
  private var currentLocationManager: LocationManager?
  private let regionSize: CLLocationDistance = 500.0
  private let distanceFilter: CLLocationDistance = 10.0

  var demoView: DemoView {
    return view as! DemoView
  }

  override func loadView() {
    let demoView = DemoView(frame: UIScreen.main.bounds)
    demoView.gpxControl.addTarget(self, action: #selector(DemoViewController.valueChanged(_:)), for: .valueChanged)
    demoView.speedStepper.addTarget(self, action: #selector(DemoViewController.stepperValueChanged(_:)), for: .valueChanged)
    demoView.speedStepper.minimumValue = minSpeed
    demoView.speedStepper.maximumValue = maxSpeed
    demoView.speedStepper.value = currentSpeed
    demoView.updateSpeedLabel(speed: currentSpeed)
    view = demoView
    startGpxFileDemo()
  }

  private func startGpxFileDemo() {
    demoView.enableSpeedControls()
    startUpdatingLocation(newLocationManager: LocationManager(type: .gpxFile(gpxFile1)))
  }

  private func startLocationsDemo() {
    demoView.enableSpeedControls()
    if let parser = GpxParser(file: gpxFile2) {
      let (_, locations) = parser.parse()
      startUpdatingLocation(newLocationManager: LocationManager(type: .locations(locations)))
    }
  }

  private func startCoreLocationDemo() {
    demoView.disableSpeedControls()
    let coreLocationManager = LocationManager(type: .coreLocation)
    coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    coreLocationManager.activityType = .fitness
    coreLocationManager.distanceFilter = distanceFilter
    coreLocationManager.pausesLocationUpdatesAutomatically = false
    coreLocationManager.requestWhenInUseAuthorization()
    startUpdatingLocation(newLocationManager: coreLocationManager)
  }

  private func startUpdatingLocation(newLocationManager: LocationManager) {
    currentLocationManager = newLocationManager
    currentLocationManager?.delegate = self
    currentLocationManager?.secondLength = 1.0 / currentSpeed
    currentLocationManager?.startUpdatingLocation()
  }

  @objc func valueChanged(_ sender: UISegmentedControl) {
    currentLocationManager?.kill()
    currentLocationManager?.stopUpdatingLocation()
    guard let demoType = DemoType.from(sender.selectedSegmentIndex) else {
      fatalError("Unsupported index selected.")
    }
    switch demoType {
    case .gpx: startGpxFileDemo()
    case .locations: startLocationsDemo()
    case .coreLocation: startCoreLocationDemo()
    }
  }

  @objc func stepperValueChanged(_ sender: UIStepper) {
    currentSpeed = sender.value
    currentLocationManager?.secondLength = 1.0 / currentSpeed
    demoView.speedLabel.text = "\(Int(currentSpeed))X"
    demoView.updateSpeedLabel(speed: currentSpeed)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    demoView.mapView.setRegion(MKCoordinateRegionMakeWithDistance(locations[0].coordinate, regionSize, regionSize), animated: true)
    demoView.mapView.removeAnnotations(demoView.mapView.annotations)
    let pin = MKPointAnnotation()
    pin.coordinate = locations[0].coordinate
    demoView.mapView.addAnnotation(pin)

    demoView.updateActualSpeedLabel(speed: locations[0].speed)
  }
}
