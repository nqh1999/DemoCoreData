//
//  EditViewController.swift
//  DemoCoreData
//
//  Created by Nguyen Quang Huy on 11/05/2022.
//

import UIKit

class EditViewController: UIViewController {
    
    var user: User!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
    }
    
    //
    func setupUI() {
        title = "Edit"
        
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
    }
    
    func setupData() {
        if let user = user {
            nameTextField.text = user.name
            ageTextField.text = "\(user.age)"
            genderSegmentedControl.selectedSegmentIndex = user.gender ? 0 : 1
        }
    }

    @objc func done() {
        /*
        --- lấy AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        --- lấy Managed Object Context
        let managedContext = appDelegate.persistentContainer.viewContext
        */
        
        let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // set giá trị cho Object
        user.name = nameTextField.text
        user.age = Int16(ageTextField.text!) ?? 0
        user.gender = genderSegmentedControl.selectedSegmentIndex == 0 ? true : false
        
        //save context
        do {
            try managedContext.save()
            self.navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

}
