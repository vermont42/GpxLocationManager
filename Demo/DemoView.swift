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
    speedLabelLabel.text = "Speed: "
    speedLabelLabel.textColor = .white
    return speedLabelLabel
  } ()

  internal let speedLabel: UILabel = {
    let speedLabel = UILabel()
    speedLabel.text = " "
    speedLabel.textColor = .white
    return speedLabel
  } ()

  private let actualSpeedLabelLabel: UILabel = {
    let actualSpeedLabelLabel = UILabel()
    actualSpeedLabelLabel.text = "Actual Speed: "
    actualSpeedLabelLabel.textColor = .white
    return actualSpeedLabelLabel
  } ()

  internal let actualSpeedLabel: UILabel = {
    let actualSpeedLabel = UILabel()
    actualSpeedLabel.text = " "
    actualSpeedLabel.textColor = .white
    return actualSpeedLabel
  } ()

  private let headingLabelLabel: UILabel = {
    let headingLabelLabel = UILabel()
    headingLabelLabel.text = "Heading: "
    headingLabelLabel.textColor = .white
    return headingLabelLabel
  } ()

  internal let headingLabel: UILabel = {
    let headingLabel = UILabel()
    headingLabel.text = " "
    headingLabel.textColor = .white
    return headingLabel
  } ()

  override init(frame: CGRect) {
    super.init(frame: frame)
    [mapView, gpxControl, speedLabelLabel, speedLabel, speedStepper, actualSpeedLabel, actualSpeedLabelLabel, headingLabelLabel, headingLabel].forEach { control in
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
    actualSpeedLabelLabel.bottomAnchor.constraint(equalTo: headingLabel.topAnchor, constant: standard * -1.0).activate()

    headingLabel.centerXAnchor.constraint(equalTo: centerXAnchor).activate()
    headingLabel.centerYAnchor.constraint(equalTo: headingLabelLabel.centerYAnchor).activate()

    headingLabelLabel.trailingAnchor.constraint(equalTo: headingLabel.leadingAnchor, constant: standard * -1.0).activate()
    headingLabelLabel.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).activate()
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

  internal func updateHeadingLabel(heading: Double) {
    headingLabel.text = "\(String(format: "%.2f", heading))°"
  }
}
