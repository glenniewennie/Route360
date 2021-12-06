//
//  SecondController.swift
//  Route360
//
//  Created by Glen Liu and Joshua Halberstadt on 11/28/21.
//

import UIKit

class SecondController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // app usage page
        
        // attribute used for bold text
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22)]
        
        // creates a string with bold text
        let fullString = NSMutableAttributedString(string: "Route From Current Location: ", attributes: attrs)
        
        // adds more tex to the string
        fullString.append(NSAttributedString(string: "\n Tap the "))
        
        // add image to the string
        let image1 = NSTextAttachment()
        image1.image = UIImage(systemName: "location.fill")
        image1.image = image1.image?.withTintColor(.label)
        let image1String = NSAttributedString(attachment: image1)
        fullString.append(image1String)
        
        // add text after image
        fullString.append(NSAttributedString(string: " icon and enter a distance in miles when prompted. The app will then generate a running route of the specified length starting at your current location"))
        
        // create and configure layout of the text block
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.attributedText = fullString
        label.textColor = .label
        
        // add the created label to the screen
        self.view.addSubview(label)
        
        // set placement of text within the UI
        let width = UIScreen.main.bounds.size.width - 20
        label.widthAnchor.constraint(equalToConstant: width).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 230).isActive = true
        
        // add bold text to new string
        let fullString2 = NSMutableAttributedString(string: "Route From Non-Current Location: ", attributes: attrs)
        // add non-bold text to string
        fullString2.append(NSAttributedString(string: "\nTap the search bar. Search for desired location and tap the entry. When prompted enter a distance in miles for the route. The app will then generate a running route of the specified length starting at your current location"))
        
        // create and configure layout of the text block
        let label2 = UILabel()
        label2.translatesAutoresizingMaskIntoConstraints = false
        label2.numberOfLines = 0
        label2.lineBreakMode = .byWordWrapping
        label2.textAlignment = .center
        label2.attributedText = fullString2
        
        // add the created label to the screen
        self.view.addSubview(label2)
        
        // set placement of text within the UI
        let width2 = UIScreen.main.bounds.size.width - 20
        label2.widthAnchor.constraint(equalToConstant: width2).isActive = true
        label2.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label2.heightAnchor.constraint(equalToConstant: 510).isActive = true
    }
}

