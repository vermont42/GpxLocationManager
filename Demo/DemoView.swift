//
//  DemoView.swift
//  GpxLocationManager
//
//  Created by Joshua Adams on 4/14/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import UIKit
import MapKit

class DemoView: UIView {
  private let standard: CGFloat = 8.0
  private let disabledAlpha: CGFloat = 0.4

  internal let mapView = MKMapView()

  internal let gpxControl: UISegmentedControl = {
    let gpxControl = UISegmentedControl(items: ["GPX File", "Locations", "Device GPS"])
    gpxControl.selectedSegmentIndex = 0
    return gpxControl
  } ()

  internal let speedStepper = UIStepper()

  private let speedLabelLabel: UILabel = {
    let speedLabelLabel = UILabel()
    speedLabelLabel.text = "Speed Rate: "
    speedLabelLabel.textColor = UIColor.white
    return speedLabelLabel
  } ()

  internal let speedLabel: UILabel = {
    let speedLabel = UILabel()
    speedLabel.text = " "
    speedLabel.textColor = UIColor.white
    return speedLabel
  } ()

  private let actualSpeedLabelLabel: UILabel = {
    let actualSpeedLabelLabel = UILabel()
    actualSpeedLabelLabel.text = "Actual Speed: "
    actualSpeedLabelLabel.textColor = UIColor.white
    return actualSpeedLabelLabel
  } ()

  internal let actualSpeedLabel: UILabel = {
    let actualSpeedLabel = UILabel()
    actualSpeedLabel.text = " "
    actualSpeedLabel.textColor = UIColor.white
    return actualSpeedLabel
  } ()
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    [mapView, gpxControl, speedLabelLabel, speedLabel, speedStepper, actualSpeedLabel, actualSpeedLabelLabel].forEach { control in
      control.enableAutoLayout()
      addSubview(control)
    }

    mapView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor).activate()
    mapView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).activate()
    mapView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).activate()
    mapView.bottomAnchor.constraint(equalTo: gpxControl.topAnchor, constant: standard * -1.0).activate()

    gpxControl.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).activate()
    gpxControl.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).activate()
    gpxControl.bottomAnchor.constraint(equalTo: speedStepper.topAnchor, constant: standard * -1.0).activate()

    speedStepper.leadingAnchor.constraint(equalTo: speedLabel.trailingAnchor, constant: standard).activate()
    speedStepper.bottomAnchor.constraint(equalTo: actualSpeedLabel.topAnchor, constant: standard * -1.0).activate()

    speedLabel.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
    speedLabel.centerYAnchor.constraint(equalTo: speedStepper.centerYAnchor).activate()

    speedLabelLabel.trailingAnchor.constraint(equalTo: speedLabel.leadingAnchor, constant: standard * -1.0).activate()
    speedLabelLabel.centerYAnchor.constraint(equalTo: speedStepper.centerYAnchor).activate()

    actualSpeedLabel.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
    actualSpeedLabel.centerYAnchor.constraint(equalTo: actualSpeedLabelLabel.centerYAnchor).activate()

    actualSpeedLabelLabel.trailingAnchor.constraint(equalTo: actualSpeedLabel.leadingAnchor, constant: standard * -1.0).activate()
    actualSpeedLabelLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: standard * -1.0).activate()

  }

  required init(coder aDecoder: NSCoder) {
    fatalError("This class does not support NSCoding.")
  }

  internal func updateSpeedLabel(speed: Double) {
    speedLabel.text = "\(Int(speed))X"
  }

  internal func enableSpeedControls() {
    [speedLabelLabel, speedLabel, speedStepper, actualSpeedLabel, actualSpeedLabelLabel].forEach { $0.alpha = 1.0 }
    speedStepper.isEnabled = true
  }

  internal func disableSpeedControls() {
    [speedLabelLabel, speedLabel, speedStepper, actualSpeedLabel, actualSpeedLabelLabel].forEach { $0.alpha = disabledAlpha }
    speedStepper.isEnabled = false
  }

  internal func updateActualSpeedLabel(speed: Double) {
    actualSpeedLabel.text = "\(String(format: "%.2f", speed)) m/s"
  }
}
