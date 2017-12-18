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
    
    @IBAction func onClickDone(_ sender: UIBarButtonItem) {
        print("Entry is being saved...")
        let personEntry = NSEntityDescription.insertNewObject(forEntityName: "PersonEntry", into: self.managedContext!) as! PersonEntry
        personEntry.name = name.text
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
