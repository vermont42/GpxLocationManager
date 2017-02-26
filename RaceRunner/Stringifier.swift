//
//  Stringifier.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/17/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation

class Stringifier {
    fileprivate static let metersInKilometer: Double = 1000.0
    fileprivate static let  metersInMile: Double = 1609.344
    fileprivate static let feetInMeter: Double = 3.281
    fileprivate static let fahrenheitMultiplier: Float = 9.0 / 5.0
    fileprivate static let celsiusFraction: Float = 5.0 / 9.0
    fileprivate static let fahrenheitAmountToAdd: Float = 32.0
    fileprivate static let fahrenheitUnitName: String = "F"
    fileprivate static let celsiusMultiplier: Float = 1.0
    fileprivate static let celsiusAmountToAdd: Float = 0.0
    fileprivate static let celsiusUnitName: String = "C"
    fileprivate static let imperialLongUnitName: String = "mi"
    fileprivate static let metricLongUnitName: String = "km"
    fileprivate static let imperialShortUnitName: String = "ft"
    fileprivate static let metricShortUnitName: String = "m"
    
    class func convertFahrenheitToCelsius(_ temperature: Float) -> Float {
        return celsiusFraction * (temperature - fahrenheitAmountToAdd)
    }
    
    class func stringifyDistance(_ meters: Double) -> String {
        var unitDivider: Double
        var unitName: String
        if SettingsManager.getUnitType() == .Metric {
            unitName = metricLongUnitName
            unitDivider = metersInKilometer
        }
        else {
            unitName = imperialLongUnitName
            unitDivider = metersInMile
        }
        return NSString(format: "%.2f %@", meters / unitDivider, unitName) as String
    }

    class func stringifySecondCount(_ seconds: Int, useLongFormat: Bool) -> String {
        var remainingSeconds = seconds
        let hours = remainingSeconds / 3600
        remainingSeconds -= hours * 3600
        let minutes = remainingSeconds / 60
        remainingSeconds -= minutes * 60
        if useLongFormat {
            if hours > 0 {
                return NSString(format: "%d hr %d min %d sec", hours, minutes, remainingSeconds) as String
            } else if minutes > 0 {
                return NSString(format: "%d min %d sec", minutes, remainingSeconds) as String
            } else {
                return NSString(format: "%d sec", remainingSeconds) as String
            }
        }
        else {
            if hours > 0 {
                return NSString(format: "%02d:%02d:%02d", hours, minutes, remainingSeconds) as String
            } else if minutes > 0 {
                return NSString(format: "%02d:%02d", minutes, remainingSeconds) as String
            } else {
                return NSString(format: "%02d", remainingSeconds) as String
            }
        }
    }
    
    class func stringifyAveragePaceFromDistance(_ meters: Double, seconds:(Int)) -> String {
        if seconds == 0 || meters == 0.0 {
            return "0"
        }
        
        let avgPaceSecMeters = Double(seconds) / meters
        var unitMultiplier: Double
        var unitName: String
        if SettingsManager.getUnitType() == .Metric {
            unitName = "min/" + metricLongUnitName
            unitMultiplier = metersInKilometer
        }
        else {
            unitName = "min/" + imperialLongUnitName
            unitMultiplier = metersInMile
        }
        let paceMin = Int((avgPaceSecMeters * unitMultiplier) / 60)
        let paceSec = Int(avgPaceSecMeters * unitMultiplier - Double((paceMin * 60)))
        return NSString(format: "%d:%02d %@", paceMin, paceSec, unitName) as String
    }

    class func stringifyAltitude(_ meters: Double) -> String {
        var unitMultiplier: Double
        var unitName: String
        if SettingsManager.getUnitType() == .Metric {
            unitMultiplier = 1.0
            unitName = metricShortUnitName
        }
        else {
            unitMultiplier = feetInMeter
            unitName = imperialShortUnitName
        }
        return NSString(format: "%.1f %@", meters * unitMultiplier, unitName) as String
    }
    
    class func stringifyTemperature(_ temperature: Float) -> String {
        var unitName: String
        var multiplier: Float
        var amountToAdd: Float
        if SettingsManager.getUnitType() == .Metric {
            unitName = celsiusUnitName
            multiplier = celsiusMultiplier
            amountToAdd = celsiusAmountToAdd
        }
        else {
            unitName = fahrenheitUnitName
            multiplier = fahrenheitMultiplier
            amountToAdd = fahrenheitAmountToAdd
        }
        return NSString(format: "%.0f° %@", temperature * multiplier + amountToAdd, unitName) as String
    }
}
