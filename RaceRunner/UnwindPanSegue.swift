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
        let secondVCView = self.sourceViewController.view as UIView!
        let firstVCView = self.destinationViewController.view as UIView!
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let window = UIApplication.sharedApplication().keyWindow
        window?.insertSubview(firstVCView, aboveSubview: secondVCView)
        UIView.animateWithDuration(UiConstants.panDuration, animations: { () -> Void in
            firstVCView.frame = CGRectOffset(firstVCView.frame, screenWidth, 0.0)
            secondVCView.frame = CGRectOffset(secondVCView.frame, screenWidth, 0.0)
            }) { (Finished) -> Void in
                self.sourceViewController.dismissViewControllerAnimated(false, completion: nil)
        }
    }
}
