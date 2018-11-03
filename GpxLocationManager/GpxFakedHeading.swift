//
//  GpxFakedHeading.swift
//  GpxLocationManager
//
//  Created by Ian Grossberg on 9/22/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import CoreLocation

open class GpxFakedHeading: CLHeading {
  internal let trueNorth: CLLocationDirection
  
  public init(trueNorth: CLLocationDirection) {
    self.trueNorth = trueNorth
    super.init()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    self.trueNorth = aDecoder.decodeDouble(forKey: "trueNorth")
    super.init(coder: aDecoder)
  }
  
  open override var magneticHeading: CLLocationDirection {
    fatalError("magneticHeading has not been implemented")
  }
  
  open override var trueHeading: CLLocationDirection {
    return self.trueNorth
  }
  
  open override var headingAccuracy: CLLocationDirection {
    return 0
  }
  
  open override var x: CLHeadingComponentValue {
    fatalError("x has not been implemented")
  }
  
  open override var y: CLHeadingComponentValue {
    fatalError("y has not been implemented")
  }
  
  open override var z: CLHeadingComponentValue {
    fatalError("z has not been implemented")
  }
  
  open override var timestamp: Date {
    fatalError("timestamp has not been implemented")
  }
}
