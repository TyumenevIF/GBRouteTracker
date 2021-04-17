//
//  User.swift
//  GBRouteTracker
//
//  Created by Ilyas Tyumenev on 14.04.2021.
//

import Foundation
import RealmSwift

final class User: Object {
    @objc dynamic var login: String?
    @objc dynamic var password: String?
    
    override class func primaryKey() -> String? {
        return "login"
    }
    
    convenience init(login: String, password: String) {
        self.init()
        self.login = login
        self.password = password
    }
}
