//
//  UpcomingTableViewController.swift
//  birthday_app
//
//  Created by David Mitterlehner on 18.12.17.
//  Copyright © 2017 David und Bernadette. All rights reserved.
//

import UIKit
import CoreData
import UserNotificationsUI
import UserNotifications

// Custom Person class is needed to sort the TableView by days left until birthday
// Every time the table is reloaded a Person array is created from the fetchedResultsController
// This array also contains the days left until birthday, which is calculated on every reload
// The Person array then provides the content for the cells of the Table View
class Person {
    var name: String
    var birthday: Date
    var daysLeft: Int
    var birthdayNextYear: Bool
    
    init(name: String, birthday: Date, daysLeft: Int, birthdayNextYear: Bool) {
        self.name = name
        self.birthday = birthday
        self.daysLeft = daysLeft
        self.birthdayNextYear = birthdayNextYear
    }
}

class UpcomingTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var personArray: [Person] = []
    
    lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
        let request = NSFetchRequest<NSManagedObject>(entityName: "PersonEntry")
        request.fetchBatchSize = 20
        request.fetchLimit = 100
        let sortDescriptor = NSSortDescriptor(key: "name", ascending:true)
        request.sortDescriptors = [sortDescriptor]
        let frc = NSFetchedResultsController<NSManagedObject>(fetchRequest: request, managedObjectContext:
            self.managedContext!, sectionNameKeyPath: nil, cacheName: "Cache")
        frc.delegate = self
        // perform initial model fetch
        do {
            try frc.performFetch()
        } catch let e as NSError {
            print("Fetch error: \(e.localizedDescription)")
            abort();
        }
        return frc
    }()
    
    lazy var managedContext: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        return appDelegate.persistentContainer.viewContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = CGFloat(75.0)
        var personArray = [Person]()
        let currentDate = Date()
        let calendar = Calendar.current
        let dayCurrent = calendar.ordinality(of: .day, in: .year, for: currentDate)
        for value in fetchedResultsController.fetchedObjects as! [NSManagedObject] {
            let name = value.value(forKey: "name") as! String
            let birthday = value.value(forKey: "birthday") as! Date
            let dayBirthday = calendar.ordinality(of: .day, in: .year, for: birthday)
            var daysLeft = dayBirthday! - dayCurrent!
            var birthdayNextYear = false
            if daysLeft < 0 {
                daysLeft = 365 + daysLeft
                birthdayNextYear = true
            }
            let person = Person(name: name, birthday: birthday, daysLeft: daysLeft, birthdayNextYear: birthdayNextYear)
            personArray.append(person)
        }
        personArray = personArray.sorted(by: {$0.daysLeft < $1.daysLeft})
        self.personArray = personArray
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections {
            let currentSection = sections[section]
            return currentSection.numberOfObjects
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "upcomingCell", for: indexPath) as! UpcomingCell
        if personArray.count > indexPath.row {
            let birthday = personArray[indexPath.row].birthday
            let name = personArray[indexPath.row].name
            let daysLeft = personArray[indexPath.row].daysLeft
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "EEEE, d. MMMM"
            let birthdayString = dateFormatter.string(from: birthday)
            cell.nameLabel.text = name
            cell.birthdayLabel.text = birthdayString
            cell.daysLeftLabel.text = String(daysLeft)
            cell.birthday = birthday
            cell.birthdayNextYear = personArray[indexPath.row].birthdayNextYear
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.managedContext?.delete(fetchedResultsController.fetchedObjects![indexPath.row])
            do {
                try self.managedContext?.save()
            } catch {
            }
            let cell = tableView.cellForRow(at: indexPath) as? UpcomingCell
            let name = cell?.nameLabel.text!
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: ["birthday_notification\(name)"])
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject:
        Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            self.tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            break
        case .move:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPerson" {
            let personVC = segue.destination as! PersonViewController
            let selectedCell = sender as! UpcomingCell
            let name = selectedCell.nameLabel.text
            let currentDate = Date()
            let birthdayComponents = Calendar.current.dateComponents([.year, .month, .day], from: selectedCell.birthday)
            let currentDayComponents = Calendar.current.dateComponents([.year, .month, .day], from: currentDate)
            var age = currentDayComponents.year! - birthdayComponents.year!
            if selectedCell.birthdayNextYear {
                age = age + 1
            }
            personVC.personNavigationBar.title = name
            personVC.birthday = selectedCell.birthdayLabel.text!
            personVC.age = age
            personVC.birthdayDate = selectedCell.birthday
        }
    }
}
