//
//  LoginViewController.swift
//  GBRouteTracker
//
//  Created by Ilyas Tyumenev on 13.04.2021.
//

import UIKit
import RealmSwift

final class LoginViewController: UIViewController {
    
    lazy var realm = try! Realm()
        
    // MARK: - Outlets
    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var router: LoginRouter!
    
    // MARK: - Actions
    @IBAction func login(_ sender: Any) {        
        guard
            let login = loginView.text,
            login.isEmpty == false,
            let password = passwordView.text,
            password.isEmpty == false
        else {
            showEmptyLoginError()
            return
        }
        
        do {
            let realm = try Realm()
            let realmUser = realm.objects(User.self).filter { $0.login == login }
            
            if realmUser.isEmpty == false && password == realmUser.first?.password {
                UserDefaults.standard.set(true, forKey: "isLogin")
                router.toMain()
            } else {
                showLoginError()
            }
        } catch {
            print(error)
        }
    }
    
    @IBAction func signUp(_ sender: Any) {
        router.toSignUp()
    }
    
    private func showEmptyLoginError() {
        let alert = UIAlertController(
            title: "Ошибка", message: "Введите логин и пароль", preferredStyle: .alert
        )
        
        let ok = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    private func showLoginError() {
        let alert = UIAlertController(
            title: "Ошибка", message: "Пользователь не зарегистрирован или неверный логин и пароль", preferredStyle: .alert
        )
        
        let ok = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}

final class LoginRouter: BaseRouter {
    
    func toMain() {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(MainViewController.self)
        setAsRoot(UINavigationController(rootViewController: controller))
    }
    
    func toSignUp() {
        let controller = UIStoryboard(name: "Auth", bundle: nil).instantiateViewController(SignUpViewController.self)
        show(controller)
    }
}