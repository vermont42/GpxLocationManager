//
//  CLLocationDirection+Utility.swift
//  Eunomia
//
//  Created by Ian Grossberg on 9/22/18.
//

import CoreLocation

extension CLLocationDirection {
  var inDegrees: Measurement<UnitAngle> {
    return Measurement(value: self, unit: UnitAngle.degrees)
  }

  var inRadians: Measurement<UnitAngle> {
    return self.inDegrees.converted(to: .radians)
  }
}
