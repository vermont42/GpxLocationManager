//
//  PanSegue.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/1/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//
//  This code is adapted from http://www.appcoda.com/custom-segue-animations/ .

import UIKit

class PanSegue: UIStoryboardSegue {
    override func perform() {
        let firstVCView = self.sourceViewController.view as UIView!
        let secondVCView = self.destinationViewController.view as UIView!
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        secondVCView.frame = CGRectMake(screenWidth, 0, screenWidth, screenHeight)
        // secondVCView.transform = CGAffineTransformRotate(secondVCView.transform, CGFloat(M_PI))

        let window = UIApplication.sharedApplication().keyWindow
        // Swizzle to avoid spurious call to viewWillAppear().
        method_exchangeImplementations(class_getInstanceMethod(destinationViewController.classForCoder, "viewWillAppear:"), class_getInstanceMethod(UIViewController.classForCoder(), "viewWillAppearNoOp:"))
        window?.insertSubview(secondVCView, aboveSubview: firstVCView)
        // Unswizzle.
        method_exchangeImplementations(class_getInstanceMethod(UIViewController.classForCoder(), "viewWillAppearNoOp:"), class_getInstanceMethod(destinationViewController.classForCoder, "viewWillAppear:"))
        UIView.animateWithDuration(UiConstants.panDuration, animations: { () -> Void in
            firstVCView.frame = CGRectOffset(firstVCView.frame, -screenWidth, 0)
            secondVCView.frame = CGRectOffset(secondVCView.frame, -screenWidth, 0)
            }) { (Finished) -> Void in
                self.sourceViewController.presentViewController(self.destinationViewController , animated: false, completion: nil)
        }
    }
}

