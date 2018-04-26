//
//  LocationService.swift
//  GpxLocationManager
//
//  Created by Nehal Kanetkar on 2018-04-26.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import Foundation

protocol LocationService {
    var locationManagerType: LocationManagerType { get }
    var locationManager: LocationManager { get }
}
