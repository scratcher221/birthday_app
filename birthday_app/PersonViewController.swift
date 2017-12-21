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
    
    var birthday = String()
    var birthdayDate = Date()
    var age = Int()
    var infoTextString = String()
    @IBOutlet weak var infoText: UITextView!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var personNavigationBar: UINavigationItem!
    @IBOutlet weak var ageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        var htmlContent = "Empty :("
        // Download HTML data
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "MMMM/d"
        let dateString = dateFormatter.string(from: birthdayDate)
        let urlString = "https://www.onthisday.com/birthdays/date/1960/\(dateString)"
        print(urlString)
        let infoUrl = URL(string: urlString)!
        let task = URLSession.shared.dataTask(with: infoUrl) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            else {
                htmlContent = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                self.parse(htmlContent: htmlContent)
                self.performSelector(onMainThread: #selector(self.updateInfoText), with: nil, waitUntilDone: false)
            }
        }
        task.resume()
        birthdayLabel.text = birthday
        let ageString = "\(age) Years"
        ageLabel.text = String.localizedStringWithFormat(NSLocalizedString("%d Years", comment: ""), age)
    }
    
    func parse(htmlContent: String) {
        do {
            let doc: Document = try! SwiftSoup.parse(htmlContent)
            let content = try! doc.getElementsByClass("event-list__item").array()
            var p1 = content[0]
            var p2 = p1
            var p3 = p1
            if content.count > 1 {
                p2 = content[1]
                if content.count > 2 {
                    p3 = content[2]
                }
            }
            let person1: String = (try! p1.text())
            var person2: String = (try! p2.text())
            var person3: String = (try! p3.text())
            if person2 == person1 {
                person2 = ""
            }
            if person3 == person1 {
                person3 = ""
            }
            let multiLineString = "\(person1)\n\n\(person2)\n\n\(person3)"
            self.infoTextString = multiLineString
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("error")
        }
    }
    
    @IBAction func updateInfoText() {
        infoText.text = infoTextString
    }
    
    
}
