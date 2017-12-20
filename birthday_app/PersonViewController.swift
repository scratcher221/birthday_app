//
//  PersonViewController.swift
//  birthday_app
//
//  Created by David Mitterlehner on 18.12.17.
//  Copyright © 2017 David und Bernadette. All rights reserved.
//

import UIKit
import Foundation
import SwiftSoup

class PersonViewController: UIViewController {
    
    var birthday = ""
    
    @IBOutlet weak var personNavigationBar: UINavigationItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        let infoUrl = URL(string: "https://www.onthisday.com/film-tv/birthdays/january/1")!
        let task = URLSession.shared.dataTask(with: infoUrl) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            else {
                let htmlContent = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                print(data!)
                print(htmlContent!)
            }
        }
        task.resume()
        
            
    }
}
