//
//  AddNewViewController.swift
//  birthday_app
//
//  Created by David Mitterlehner on 18.12.17.
//  Copyright © 2017 David und Bernadette. All rights reserved.
//

import UIKit
import CoreData

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
        performSegue(withIdentifier: "showUpcoming", sender: self)
    }
    func save() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.saveContext()
    }
    
    
}
