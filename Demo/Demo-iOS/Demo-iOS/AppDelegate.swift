//
//  AppDelegate.swift
//  Demo-iOS
//
//  Created by Constantine Fry on 13/01/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import UIKit
import WunderlistTouch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
            let client = Client(
                clientId:       "fd3f44400c55e3e7f2ec",
                clientSecret:   "bfdb1ce5c05c74733127eff743c82f25e90fd5c31a5f6c30a45fd46e50ec",
                redirectURL:    "http://fakeredirecturl.com/wunderlist_callback")
            let configuration = Configuration(client: client)
            Session.setupSharedSession(configuration)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }


}

