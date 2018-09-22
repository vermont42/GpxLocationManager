//
//  CLLocation+Utility.swift
//  Eunomia
//
//  Created by Ian Grossberg on 8/24/18.
//  Copyright © 2018 Adorkable. All rights reserved.
//

import Foundation
import CoreLocation

extension CLLocation {
    func heading(to: CLLocation) -> Measurement<UnitAngle> {
        return self.coordinate.heading(to: to.coordinate)
    }

    func heading(to: CLLocation) -> CLLocationDirection {
        return self.coordinate.heading(to: to.coordinate)
    }
}
