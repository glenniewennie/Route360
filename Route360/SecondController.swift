//
//  SecondController.swift
//  Route360
//
//  Created by Joshua Halberstadt on 11/30/21.
//

import UIKit

class SecondController: UIViewController {

    
    @IBOutlet weak var stepOne: UITextField!
    @IBOutlet weak var stepTwo: UITextField!
    @IBOutlet weak var stepThree: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instructions
        stepOne.text = "If you want to find a route from your current location, press the "
        
    }

}

