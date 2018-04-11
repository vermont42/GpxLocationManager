//
//  ViewController.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 4/11/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import UIKit
import GpxLocationManager
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
  override func viewDidLoad() {
    super.viewDidLoad()
    let manager1 = LocationManager(type: .gpxFile("iSmoothRun.gpx"))
    manager1.delegate = self
    let manager2 = LocationManager(type: .locations([]))
    manager2.delegate = self
    let manager3 = LocationManager(type: .coreLocation)
    manager3.delegate = self
  }
}
