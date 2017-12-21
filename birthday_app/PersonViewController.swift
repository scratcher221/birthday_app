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
    var age = Int()
    @IBOutlet weak var infoText: UITextView!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var personNavigationBar: UINavigationItem!
    @IBOutlet weak var ageLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        var htmlContent = "Empty :("
        // Download HTML data
        let infoUrl = URL(string: "https://www.onthisday.com/date/1960/december/29")!
        let task = URLSession.shared.dataTask(with: infoUrl) { (data, response, error) in
            if error != nil {
                print(error!)
            }
            else {
                htmlContent = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
                self.parse(htmlContent: htmlContent)
            }
        }
        task.resume()
        birthdayLabel.text = birthday
        ageLabel.text = String(age)
    }
    
    func parse(htmlContent: String) {
        do {
            let doc: Document = try! SwiftSoup.parse(htmlContent)
            /*let link: Element = try! doc.select("a").first()!
            let text: String = try! doc.body()!.text(); // "An example link"
            let linkHref: String = try! link.attr("href"); // "http://example.com/"
            let linkText: String = try! link.text(); // "example""
            let linkOuterH: String = try! link.outerHtml(); // "<a href="http://example.com"><b>example</b></a>"
            let linkInnerH: String = try! link.html(); // "<b>example</b>"*/
            let content = try! doc.getElementsByClass("event-list__item").array()
            let test = content[0]
            let text: String = (try! test.text())
            print(text)
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("error")
        }
    }
}
