//
//  AppDelegate.swift
//  RaceRunner
//
//  Created by Joshua Adams on 3/7/15.
//  Copyright (c) 2015 Josh Adams. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //application.statusBarHidden = true
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        CDManager.saveContext()
    }

    func applicationDidEnterBackground(application: UIApplication) {}

    func applicationWillEnterForeground(application: UIApplication) {}

    func applicationDidBecomeActive(application: UIApplication) {}

    func applicationWillTerminate(application: UIApplication) {
        CDManager.saveContext()
    }
}

