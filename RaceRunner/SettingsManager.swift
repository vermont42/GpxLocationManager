//
//  SettingsManager.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/26/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation

class SettingsManager {
    private static let settingsManager = SettingsManager()
    private var userDefaults: NSUserDefaults
    
    private var unitType: UnitType
    private static let unitTypeKey = "UnitType"
    enum UnitType: String {
        case Imperial = "Imperial"
        case Metric = "Metric"
        init() {
            self = .Imperial
        }
    }
    
    private var alreadyMadeSampleRun: Bool
    private static let alreadyMadeSampleRunKey = "alreadyMadeSampleRun"
    private static let alreadyMadeSampleRunDefault = false
    
    private var multiplier: Double
    private static let multiplierKey = "Multiplier"
    private static let multiplierDefault = 5.0

    private init() {
        userDefaults = NSUserDefaults.standardUserDefaults()
        
        if let storedUnitTypeString = userDefaults.stringForKey(SettingsManager.unitTypeKey) {
            unitType = UnitType(rawValue: storedUnitTypeString)!
        }
        else {
            unitType = UnitType()
            userDefaults.setObject(unitType.rawValue, forKey: SettingsManager.unitTypeKey)
            userDefaults.synchronize()
        }
        
        if let storedAlreadyMadeSampleRunString = userDefaults.stringForKey(SettingsManager.alreadyMadeSampleRunKey) {
            alreadyMadeSampleRun = (storedAlreadyMadeSampleRunString as NSString).boolValue
        }
        else {
            alreadyMadeSampleRun = SettingsManager.alreadyMadeSampleRunDefault
            userDefaults.setObject("\(alreadyMadeSampleRun)", forKey: SettingsManager.alreadyMadeSampleRunKey)
            userDefaults.synchronize()
        }
        
        if let storedMultiplierString = userDefaults.stringForKey(SettingsManager.multiplierKey) {
            multiplier = (storedMultiplierString as NSString).doubleValue
        }
        else {
            multiplier = SettingsManager.multiplierDefault
            userDefaults.setObject(String(format:"%f", multiplier), forKey: SettingsManager.multiplierKey)
            userDefaults.synchronize()
        }
    }
    
    class func getUnitType() -> UnitType {
        return settingsManager.unitType
    }

    class func setUnitType(unitType: UnitType) {
        if unitType != settingsManager.unitType {
            settingsManager.unitType = unitType
            settingsManager.userDefaults.setObject(unitType.rawValue, forKey: SettingsManager.unitTypeKey)
            settingsManager.userDefaults.synchronize()
        }
    }
    
    class func getAlreadyMadeSampleRun() -> Bool {
        return settingsManager.alreadyMadeSampleRun
    }
    
    class func setAlreadyMadeSampleRun(alreadyMadeSampleRun: Bool) {
        if alreadyMadeSampleRun != settingsManager.alreadyMadeSampleRun {
            settingsManager.alreadyMadeSampleRun = alreadyMadeSampleRun
            settingsManager.userDefaults.setObject("\(alreadyMadeSampleRun)", forKey: SettingsManager.alreadyMadeSampleRunKey)
            settingsManager.userDefaults.synchronize()
        }
    }
    
    class func getMultiplier() -> Double {
        return settingsManager.multiplier
    }
    
    class func setMultiplier(multiplier: Double) {
        if multiplier != settingsManager.multiplier {
            settingsManager.multiplier = multiplier
            settingsManager.userDefaults.setObject(String(format:"%f", multiplier), forKey: SettingsManager.multiplierKey)
            settingsManager.userDefaults.synchronize()
        }
    }
}