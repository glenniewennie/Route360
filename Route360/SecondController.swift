//
//  SecondController.swift
//  Route360
//
//  Created by Joshua Halberstadt on 11/30/21.
//

import UIKit

class SecondController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        /*
        let selector = #selector(dismiss as () -> Void)
        let myViewController = UIViewController()
        let navController = UINavigationController(rootViewController: myViewController)
        myViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: selector
        )
        self.navigationController!.present(navController, animated: true, completion: nil)
         */
    }
    
    @objc func dismiss() {
        self.dismiss(animated: true)
    }
}

