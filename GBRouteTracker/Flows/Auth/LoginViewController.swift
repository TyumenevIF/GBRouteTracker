//
//  LoginViewController.swift
//  GBRouteTracker
//
//  Created by Ilyas Tyumenev on 13.04.2021.
//

import UIKit
import RealmSwift
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {
    
    lazy var realm = try! Realm()
    let curtainVC = CurtainViewController()
        
    // MARK: - Outlets
    @IBOutlet weak var loginView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var router: LoginRouter!
    @IBOutlet weak var loginButton: UIButton!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLoginBindings()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(
            self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil
        )
        notificationCenter.addObserver(
            self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil
        )
    }
    
    @objc func appMovedToForeground() {
        curtainVC.heightConstraint?.isActive = false
        curtainVC.view.removeFromSuperview()
    }
    
    @objc func appMovedToBackground() {
        curtainVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(curtainVC.view)
        
        NSLayoutConstraint.activate([
            curtainVC.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            curtainVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            curtainVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            curtainVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    @IBAction func login(_ sender: Any) {
        guard
            let login = loginView.text,
            login.isEmpty == false,
            let password = passwordView.text,
            password.isEmpty == false
        else {
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
    
    func configureLoginBindings() {
        Observable
            .combineLatest(
                loginView.rx.text,
                passwordView.rx.text
            )
            .map { login, password in
                return !(login ?? "").isEmpty && !(password ?? "").isEmpty
            }
            .bind { [weak loginButton] inputFilled in
                loginButton?.isEnabled = inputFilled
            }
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
