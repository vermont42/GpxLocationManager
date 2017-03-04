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
        case stationary
        case west
        case east
    }
    
    fileprivate let stationaryIcon = UIImage(named: "stationary.png")!
    fileprivate let westIcons = [UIImage(named: "west1.png")!, UIImage(named: "west2.png")!, UIImage(named: "west3.png")!, UIImage(named: "west4.png")!, UIImage(named: "west5.png")!, UIImage(named: "west6.png")!, UIImage(named: "west7.png")!, UIImage(named: "west8.png")!, UIImage(named: "west9.png")!, UIImage(named: "west10.png")!]
    fileprivate let eastIcons = [UIImage(named: "east1.png")!, UIImage(named: "east2.png")!, UIImage(named: "east3.png")!, UIImage(named: "east4.png")!, UIImage(named: "east5.png")!, UIImage(named: "east6.png")!, UIImage(named: "east7.png")!, UIImage(named: "east8.png")!, UIImage(named: "east9.png")!, UIImage(named: "east10.png")!]
    var currentIndex: Int = 0
    var direction: Direction = .stationary {
        willSet {
            if newValue == .stationary {
                currentIndex = 0
            }
        }
    }
        
    func nextIcon() -> UIImage {
        switch direction {
        case .stationary:
            return stationaryIcon
        case .west:
            let westIcon = westIcons[currentIndex];
            if currentIndex == westIcons.count - 1 {
                currentIndex = 0
            }
            else {
                currentIndex += 1
            }
            return westIcon
        case .east:
            let eastIcon = eastIcons[currentIndex];
            if currentIndex == eastIcons.count - 1 {
                currentIndex = 0
            }
            else {
                currentIndex += 1
            }
            return eastIcon
        }
    }
}
