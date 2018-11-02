//
//  CLLocationCoordinate2D.swift
//  Tracks
//
//  Created by Ian Grossberg on 8/22/18.
//

import CoreLocation

extension CLLocationCoordinate2D {
  var asMeasurement: (Measurement<UnitAngle>, Measurement<UnitAngle>) {
    return (
      self.latitude.inRadians,
      self.longitude.inRadians
    )
  }

  var inRadians: (Double, Double) {
  let asMeasurement = self.asMeasurement
    return (
      asMeasurement.0.value,
      asMeasurement.1.value
    )
  }
}

extension CLLocationCoordinate2D {
  func heading(to: CLLocationCoordinate2D) -> Measurement<UnitAngle> {
    let inRadians = (self.latitude.inRadians, self.longitude.inRadians)
    let toInRadians = (to.latitude.inRadians, to.longitude.inRadians)

    let delta = (
        toInRadians.0 - inRadians.0,
        toInRadians.1 - inRadians.1
      )

    let y = sin(delta.1.value) * cos(toInRadians.0.value)
    let x = cos(inRadians.0.value) * sin(toInRadians.0.value) - sin(inRadians.0.value) * cos(toInRadians.0.value) * cos(delta.1.value)
    let heading = atan2(y, x)

    return Measurement(value: heading, unit: UnitAngle.radians)
  }

  func heading(to: CLLocationCoordinate2D) -> CLLocationDirection {
    let measurement: Measurement<UnitAngle> = self.heading(to: to)
      return measurement.converted(to: .degrees).value
  }
}
