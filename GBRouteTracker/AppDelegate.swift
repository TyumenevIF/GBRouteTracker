//
//  AppDelegate.swift
//  GBRouteTracker
//
//  Created by Ilyas Tyumenev on 03.04.2021.
//

import UIKit
import GoogleMaps
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey("AIzaSyD3ekp15-E3GzUSwDsL04fsQZJbBGO0u2Q")
        
        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = config
        print("\nDirectory Realm:", getDocumentsDirectory())        
        return true
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        return paths[0]
    }
}
