//
//  AddNewViewController.swift
//  birthday_app
//
//  Created by David Mitterlehner on 18.12.17.
//  Copyright © 2017 David und Bernadette. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import UserNotificationsUI

class AddNewViewController: UIViewController {
    
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var birthday: UIDatePicker!
    
    // define Context for Core Data
    lazy var managedContext: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showUpcoming" {
            print("YEA")
            let tabBarController = segue.destination as! UITabBarController
            tabBarController.selectedIndex = 0
            let navigationController = tabBarController.selectedViewController as! UINavigationController
            let tVC = navigationController.visibleViewController as! UpcomingTableViewController
            tVC.tableView.reloadData()
        }
    }
    
    @IBAction func onClick(_ sender: UIBarButtonItem) {
        print("Entry is being saved...")
        let personEntry = NSEntityDescription.insertNewObject(forEntityName: "PersonEntry", into: self.managedContext!) as! PersonEntry
        personEntry.name = name.text
        personEntry.birthday = birthday.date
        save()
        createNewNotification(birthday: birthday.date, name: name.text!)
        
        performSegue(withIdentifier: "showUpcoming", sender: self)
    }
    
    func save() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.saveContext()
    }
    
    func createNewNotification(birthday: Date, name: String) {
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("Birthday Notification", comment: "")
        content.body = String.localizedStringWithFormat(NSLocalizedString("It's %@'s birthday today!", comment: ""), name)
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = "default_category"
        
        var triggerDate = Calendar.current.dateComponents([.month,.day,.hour,.minute,], from: birthday)
        triggerDate.hour = 22
        triggerDate.minute = 56
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: true)
        let request = UNNotificationRequest(identifier: "birthday_notification", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if error != nil {
                print("An error occured.")
            }
        }
    }
    
    
}
