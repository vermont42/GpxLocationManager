//
//  RunnerIcons.swift
//  RaceRunner
//
//  Created by Joshua Adams on 4/17/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation
import UIKit

class RunnerIcons {
    enum Direction {
        case Stationary
        case West
        case East
    }
    
    private let stationaryIcon = UIImage(named: "stationary.png")!
    private let westIcons = [UIImage(named: "west1.png")!, UIImage(named: "west2.png")!, UIImage(named: "west3.png")!, UIImage(named: "west4.png")!, UIImage(named: "west5.png")!, UIImage(named: "west6.png")!, UIImage(named: "west7.png")!, UIImage(named: "west8.png")!, UIImage(named: "west9.png")!, UIImage(named: "west10.png")!]
    private let eastIcons = [UIImage(named: "east1.png")!, UIImage(named: "east2.png")!, UIImage(named: "east3.png")!, UIImage(named: "east4.png")!, UIImage(named: "east5.png")!, UIImage(named: "east6.png")!, UIImage(named: "east7.png")!, UIImage(named: "east8.png")!, UIImage(named: "east9.png")!, UIImage(named: "east10.png")!]
    var currentIndex: Int = 0
    var direction: Direction = .Stationary {
        willSet {
            if newValue == .Stationary {
                currentIndex = 0
            }
        }
    }
        
    func nextIcon() -> UIImage {
        switch direction {
        case .Stationary:
            return stationaryIcon
        case .West:
            let westIcon = westIcons[currentIndex];
            if currentIndex == westIcons.count - 1 {
                currentIndex = 0
            }
            else {
                currentIndex++
            }
            return westIcon
        case .East:
            let eastIcon = eastIcons[currentIndex];
            if currentIndex == eastIcons.count - 1 {
                currentIndex = 0
            }
            else {
                currentIndex++
            }
            return eastIcon
        }
    }
}
