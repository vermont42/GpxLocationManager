//
//  SettingsManager.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/26/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import Foundation

class SettingsManager {
    fileprivate static let settingsManager = SettingsManager()
    fileprivate var userDefaults: UserDefaults
    
    fileprivate var unitType: UnitType
    fileprivate static let unitTypeKey = "UnitType"
    enum UnitType: String {
        case Imperial = "Imperial"
        case Metric = "Metric"
        init() {
            self = .Imperial
        }
    }
    
    fileprivate var alreadyMadeSampleRun: Bool
    fileprivate static let alreadyMadeSampleRunKey = "alreadyMadeSampleRun"
    fileprivate static let alreadyMadeSampleRunDefault = false
    
    fileprivate var multiplier: Double
    fileprivate static let multiplierKey = "Multiplier"
    fileprivate static let multiplierDefault = 5.0

    fileprivate init() {
        userDefaults = UserDefaults.standard
        
        if let storedUnitTypeString = userDefaults.string(forKey: SettingsManager.unitTypeKey) {
            unitType = UnitType(rawValue: storedUnitTypeString)!
        }
        else {
            unitType = UnitType()
            userDefaults.set(unitType.rawValue, forKey: SettingsManager.unitTypeKey)
            userDefaults.synchronize()
        }
        
        if let storedAlreadyMadeSampleRunString = userDefaults.string(forKey: SettingsManager.alreadyMadeSampleRunKey) {
            alreadyMadeSampleRun = (storedAlreadyMadeSampleRunString as NSString).boolValue
        }
        else {
            alreadyMadeSampleRun = SettingsManager.alreadyMadeSampleRunDefault
            userDefaults.set("\(alreadyMadeSampleRun)", forKey: SettingsManager.alreadyMadeSampleRunKey)
            userDefaults.synchronize()
        }
        
        if let storedMultiplierString = userDefaults.string(forKey: SettingsManager.multiplierKey) {
            multiplier = (storedMultiplierString as NSString).doubleValue
        }
        else {
            multiplier = SettingsManager.multiplierDefault
            userDefaults.set(String(format:"%f", multiplier), forKey: SettingsManager.multiplierKey)
            userDefaults.synchronize()
        }
    }
    
    class func getUnitType() -> UnitType {
        return settingsManager.unitType
    }

    class func setUnitType(_ unitType: UnitType) {
        if unitType != settingsManager.unitType {
            settingsManager.unitType = unitType
            settingsManager.userDefaults.set(unitType.rawValue, forKey: SettingsManager.unitTypeKey)
            settingsManager.userDefaults.synchronize()
        }
    }
    
    class func getAlreadyMadeSampleRun() -> Bool {
        return settingsManager.alreadyMadeSampleRun
    }
    
    class func setAlreadyMadeSampleRun(_ alreadyMadeSampleRun: Bool) {
        if alreadyMadeSampleRun != settingsManager.alreadyMadeSampleRun {
            settingsManager.alreadyMadeSampleRun = alreadyMadeSampleRun
            settingsManager.userDefaults.set("\(alreadyMadeSampleRun)", forKey: SettingsManager.alreadyMadeSampleRunKey)
            settingsManager.userDefaults.synchronize()
        }
    }
    
    class func getMultiplier() -> Double {
        return settingsManager.multiplier
    }
    
    class func setMultiplier(_ multiplier: Double) {
        if multiplier != settingsManager.multiplier {
            settingsManager.multiplier = multiplier
            settingsManager.userDefaults.set(String(format:"%f", multiplier), forKey: SettingsManager.multiplierKey)
            settingsManager.userDefaults.synchronize()
        }
    }
}
