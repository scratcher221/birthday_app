//
//  ViewController.swift
//  birthday_app
//
//  Created by David Mitterlehner on 16.12.17.
//  Copyright © 2017 David und Bernadette. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        performSegue(withIdentifier: "showTabBarController", sender: self)
    }

}

