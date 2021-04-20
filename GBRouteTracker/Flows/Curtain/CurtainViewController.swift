//
//  CurtainViewController.swift
//  GBRouteTracker
//
//  Created by Ilyas Tyumenev on 18.04.2021.
//

import UIKit

class CurtainViewController: UIViewController {
    
    let containerVC: ContainerViewController = {
        let vc = ContainerViewController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        return vc
    }()
    
    var heightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupContainerView()
    }
    
    func setupContainerView() {
        [containerVC].forEach { (viewController) in
            self.view.addSubview(viewController.view)
        }
        
        heightConstraint = containerVC.view.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            containerVC.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            containerVC.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            containerVC.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            heightConstraint
        ])
        
        let screenSize = UIScreen.main.bounds
        let heightValue = screenSize.size.height
        self.view.layoutIfNeeded()
        
        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0,
            options: UIView.AnimationOptions.curveEaseIn,
            animations: {
                self.heightConstraint.constant =  heightValue
                self.view.layoutIfNeeded()
            }, completion: nil)
    }
}
