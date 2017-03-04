//
//  LogCell.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/15/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {

    @IBOutlet var pace: UILabel!
    @IBOutlet var distance: UILabel!
    @IBOutlet var dateTime: UILabel!
    @IBOutlet var duration: UILabel!
    @IBOutlet var route: UILabel!
    
    func displayRun(_ run: Run) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateTime.text = dateFormatter.string(from: run.timestamp as Date)
        duration.text = Stringifier.stringifySecondCount(run.duration.intValue, useLongFormat: false)
        pace.text = Stringifier.stringifyAveragePaceFromDistance(run.distance.doubleValue, seconds: run.duration.intValue)
        distance.text = Stringifier.stringifyDistance(run.distance.doubleValue)
        if run.customName == "" {
            route.text = run.autoName as String
        }
        else {
            route.text = run.customName as String
        }
    }
}
