//
//  HomeViewController.swift
//  Box8LoginAssignment
//
//  Created by Kavya on 9/29/18.
//  Copyright © 2018 Level. All rights reserved.
//

import UIKit
import CoreData


class HomeViewController: UIViewController {
    var userData : NSManagedObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func logoutButtonAction(_ sender: UIButton) {
       self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func signoutBtnAction(_ sender: UIButton) {
        let loggedInUserEmail = self.userData!.value(forKey: "emailID") as! String
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        if let result = try? context.fetch(fetchRequest) {
            for object in result {
                print("userEmail:",loggedInUserEmail)
                let email = (object as! NSManagedObject).value(forKey: "emailID") as! String
                print(email)
                if email == loggedInUserEmail {
                    context.delete(object as! NSManagedObject)
                    do {
                        try context.save()
                        print("Deleted")
                        self.navigationController?.popViewController(animated: true)
                    } catch {
                        print("Error Deleting")
                    }
                    
                }
            }
        }
    }
    
}
