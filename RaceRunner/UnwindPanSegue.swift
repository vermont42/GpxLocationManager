//
//  UnwindPanSegue.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

class UnwindPanSegue: UIStoryboardSegue {
    override func perform() {
        let secondVCView = self.source.view as UIView!
        let firstVCView = self.destination.view as UIView!
        let screenWidth = UIScreen.main.bounds.size.width
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(firstVCView!, aboveSubview: secondVCView!)
        UIView.animate(withDuration: UiConstants.panDuration, animations: { () -> Void in
            firstVCView?.frame = (firstVCView?.frame.offsetBy(dx: screenWidth, dy: 0.0))!
            secondVCView?.frame = (secondVCView?.frame.offsetBy(dx: screenWidth, dy: 0.0))!
            }) { (Finished) -> Void in
                self.source.dismiss(animated: false, completion: nil)
        }
    }
}
