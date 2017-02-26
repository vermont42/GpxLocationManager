//
//  SettingsVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class SettingsVC: ChildVC {
    @IBOutlet var units: UISwitch!
    @IBOutlet var multiplierSlider: UISlider!
    @IBOutlet var multiplierLabel: UILabel!
    @IBOutlet var viewControllerTitle: UILabel!
    @IBOutlet var showMenuButton: UIButton!
    
    @IBAction func showMenu(_ sender: UIButton) {
        showMenu()
    }
    
    override func viewDidLoad() {
        if SettingsManager.getUnitType() == .Imperial {
            units.isOn = false
        }
        else {
            units.isOn = true
        }
        updateMultiplierLabel()
        multiplierSlider.value = Float(SettingsManager.getMultiplier())
        viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
        showMenuButton.setImage(UiHelpers.maskedImageNamed("menu", color: UiConstants.lightColor), for: UIControlState())
    }
    
    @IBAction func toggleUnitType(_ sender: UISwitch) {
        if sender.isOn {
            SettingsManager.setUnitType(.Metric)
        }
        else {
            SettingsManager.setUnitType(.Imperial)
        }
    }
    
    @IBAction func multiplierChanged(_ sender: UISlider) {
        SettingsManager.setMultiplier(round(Double(sender.value)))
        updateMultiplierLabel()
    }
    
    func updateMultiplierLabel() {
        multiplierLabel.text = String(format: "%.0f%%", SettingsManager.getMultiplier() * 100.0)
    }
}
