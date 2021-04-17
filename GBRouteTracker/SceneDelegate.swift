//
//  SceneDelegate.swift
//  GBRouteTracker
//
//  Created by Ilyas Tyumenev on 03.04.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let controller: UIViewController
        
        if UserDefaults.standard.bool(forKey: "isLogin") {
            controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(MainViewController.self)
        } else {
            controller = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(LoginViewController.self)
        }
        
        window?.rootViewController = UINavigationController(rootViewController: controller)
        window?.makeKeyAndVisible()
    }
}
