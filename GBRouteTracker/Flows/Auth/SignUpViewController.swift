//
//  RecoveryPasswordViewController.swift
//  GBRouteTracker
//
//  Created by Ilyas Tyumenev on 13.04.2021.
//

import UIKit
import RealmSwift

final class SignUpViewController: UIViewController {
    
    lazy var realm = try! Realm()
    
    // MARK: - Outlets
    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    
    // MARK: - Actions
    @IBAction func signUp(_ sender: Any) {        
        guard
            let login = loginView.text,
            login.isEmpty == false,
            let password = passwordView.text,
            password.isEmpty == false
        else {
            showEmptySignUpError()
            return
        }
        
        do {
            let realm = try Realm()
            let realmUser = realm.objects(User.self)
            let checkUser = realm.objects(User.self).filter { $0.login == login }
            let newUser = User(login: loginView.text!, password: passwordView.text!)
            
            if realmUser.isEmpty {
                try realm.write {
                    realm.add(newUser)
                }
            } else {
                
                if checkUser.isEmpty == false && login == checkUser.first?.login {
                    showSignUpError()
                }
                
                try realm.write {
                    realm.add(newUser, update: .modified)
                }
            }
        } catch {
            print(error)
        }
    }
    
    private func showEmptySignUpError() {
        let alert = UIAlertController(
            title: "Ошибка", message: "Введите логин и пароль", preferredStyle: .alert
        )
        
        let ok = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
    
    private func showSignUpError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Пользователь с таким логином уже зарегистрирован. Пароль будет изменен",
            preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true)
    }
}
