//
//  AppDelegate.swift
//  GBRouteTracker
//
//  Created by Ilyas Tyumenev on 03.04.2021.
//

import UIKit
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey("AIzaSyD3ekp15-E3GzUSwDsL04fsQZJbBGO0u2Q")
        
        return true
    }
}
