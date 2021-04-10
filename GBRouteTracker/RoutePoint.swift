//
//  Route.swift
//  GBRouteTracker
//
//  Created by Ilyas Tyumenev on 09.04.2021.
//

import Foundation
import RealmSwift
import CoreLocation

final class RoutePoint: Object {
    @objc dynamic var timeStamp: Date?
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0

    convenience init(location: CLLocation) {
        self.init()
        self.timeStamp = location.timestamp
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
    }
}
