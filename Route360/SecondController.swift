//
//  SecondController.swift
//  Route360
//
//  Created by Glen Liu and Joshua Halberstadt on 11/28/21.
//

import UIKit

class SecondController: UIViewController {

    
    @IBOutlet weak var stepOne: UITextField!
    @IBOutlet weak var stepTwo: UITextField!
    @IBOutlet weak var stepThree: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Instructions
       // label = [[UILabel alloc] initWithFrame: CGRect(60, 30, 200, 12)]
        //label.textAlignment = NSTextAlignment.center
        
        stepOne.text = "If you want to find a route from your current location, press the "
        
    }

}

