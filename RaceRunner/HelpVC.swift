//
//  HelpVC.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class HelpVC: ChildVC {
    @IBOutlet var viewControllerTitle: UILabel!
    @IBOutlet var showMenuButton: UIButton!
    
    @IBAction func showMenu(sender: UIButton) {
        showMenu()
    }
    
    override func viewDidLoad() {
        viewControllerTitle.attributedText = UiHelpers.letterPressedText(viewControllerTitle.text!)
        showMenuButton.setImage(UiHelpers.maskedImageNamed("menu", color: UiConstants.lightColor), forState: .Normal)
        super.viewDidLoad()
    }
}