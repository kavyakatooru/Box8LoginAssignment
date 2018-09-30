//
//  LoginViewModel.swift
//  Box8LoginAssignment
//
//  Created by Kavya on 9/29/18.
//  Copyright © 2018 Level. All rights reserved.
//

import Foundation
import UIKit
import CoreData

extension LoginViewController {
    
    func saveDataToCoreData(loginField : String? = nil) {
        self.fetchFromCoreData { (responseObj : [Any]?, error : NSError?) in
            if error == nil {
                if responseObj?.count == 0 {
                    let newUserObj = NSManagedObject(entity: self.entity!, insertInto: self.context)
                    newUserObj.setValue(self.nameTextField.text!, forKey: "userName")
                    newUserObj.setValue(self.passwordTextField.text!, forKey: "password")
                    newUserObj.setValue(self.emailTextField.text!, forKey: "emailID")
                    newUserObj.setValue(self.phoneTextField.text!, forKey: "phoneNumber")
                    do {
                        try self.context!.save()
                        print("Context saved")
                        self.showAlert(title: "Signed Up Successfully!", message: "")
                    } catch {
                        print("Failed saving")
                        self.showAlert(title: "Saving Data failed", message: "")
                    }
                } else {
                    self.showAlert(title: "User Exists Already!", message: "")
                }
            }
        }
    }
    
    func fetchFromCoreData(loginField : String? = nil,responseBlock :@escaping (_ responseObject: [Any]?, _ error : NSError?) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        print("Fetch predicate:",self.emailTextField.text!)
        if self.loginSegmentControl.selectedSegmentIndex == 0 {
            fetchRequest.predicate = NSPredicate(format: "(emailID == %@) OR (phoneNumber == %@)", loginField!,loginField!)
        }else {
            fetchRequest.predicate = NSPredicate(format: "(emailID == %@) OR (phoneNumber == %@)", self.emailTextField.text!, self.phoneTextField.text!)
        }
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let result = try self.context!.fetch(fetchRequest)
            responseBlock(result,nil);
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            responseBlock(nil,error);
        }
    }

}
