//
//  HomeViewController.swift
//  DemoCoreData
//
//  Created by Nguyen Quang Huy on 11/05/2022.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchedResultsController: NSFetchedResultsController<User>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }

    func setupUI() {
        title = "Home"

        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: "HomeCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        // add
        let addNewBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNew))
        self.navigationItem.rightBarButtonItem = addNewBarButtonItem
        
        // delete
        let deleteBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleleAll))
        self.navigationItem.leftBarButtonItem = deleteBarButtonItem
    }

    func setupData() {
        initializeFetchedResultsController()
    }
    
    //MARK: - Navigation Bar
    @objc func addNew() {
        let vc = NewViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func deleleAll() {
        let alert = UIAlertController(title: "Confirm",
                                       message: "Do you want to delete all item?",
                                       preferredStyle: .alert)
         
        let saveAction = UIAlertAction(title: "OK", style: .default) { (alert) in
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            do {
                try self.managedContext.execute(deleteRequest)
                try self.managedContext.save()
                try self.fetchedResultsController.performFetch()
                self.tableView.reloadData()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
         let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
         alert.addAction(saveAction)
         alert.addAction(cancelAction)
         present(alert, animated: true)
    }
    
    func save(name: String, age: Int, gender: Bool) {
        let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        let user = NSManagedObject(entity: entity, insertInto: managedContext)
        user.setValue(name, forKeyPath: "name")
        user.setValue(age, forKeyPath: "age")
        user.setValue(gender, forKeyPath: "gender")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.fetchedObjects!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeCell
        let user = fetchedResultsController.object(at: indexPath)
        cell.nameLabel.text = user.name
        cell.ageLabel.text = "\(user.age) years old"
        cell.genderLabel.text = user.gender ? "Male" : "Female"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = EditViewController()
        vc.user = fetchedResultsController.object(at: indexPath)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = fetchedResultsController.object(at: indexPath)
            managedContext.delete(user)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
}

//Adding Sections
extension HomeViewController: NSFetchedResultsControllerDelegate {
    func initializeFetchedResultsController() {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        //fetchRequest.predicate = NSPredicate(format: "gender == true")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedContext,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    // delegate
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .automatic)
            break;
        default:
            print("default")
        }
    }
    
}
