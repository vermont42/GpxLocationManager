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
    
    func displayRun(run: Run) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        dateTime.text = dateFormatter.stringFromDate(run.timestamp)
        duration.text = Stringifier.stringifySecondCount(run.duration.integerValue, useLongFormat: false)
        pace.text = Stringifier.stringifyAveragePaceFromDistance(run.distance.doubleValue, seconds: run.duration.integerValue)
        distance.text = Stringifier.stringifyDistance(run.distance.doubleValue)
        if run.customName == "" {
            route.text = run.autoName as String
        }
        else {
            route.text = run.customName as String
        }
    }
}
