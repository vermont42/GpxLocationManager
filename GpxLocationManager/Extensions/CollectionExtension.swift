//
//  CollectionExtension.swift
//  GpxLocationManager
//
//  Created by Nehal Kanetkar on 2018-11-19.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import Foundation

extension Collection {
    public func get(at: Index) -> Iterator.Element? {
        return indices.contains(at) ? self[at] : nil
    }
}
