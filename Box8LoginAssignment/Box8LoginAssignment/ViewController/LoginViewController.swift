//
//  LoginViewController.swift
//  Box8LoginAssignment
//
//  Created by Kavya on 9/28/18.
//  Copyright © 2018 Level. All rights reserved.
//

import UIKit
import CoreData



class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    @IBOutlet weak var userInputView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var loginSegmentControl: UISegmentedControl!
    
    @IBOutlet weak var inputViewHeightConstraint: NSLayoutConstraint!
    var newUser : NSManagedObject?
    var context : NSManagedObjectContext?
    var entity : NSEntityDescription?
    
    var buttonBar : UIView?
    var signupBottomConstraintValue : CGFloat?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.context = appDelegate.persistentContainer.viewContext
        self.entity = NSEntityDescription.entity(forEntityName: "Users", in: self.context!)
        self.emailTextField.becomeFirstResponder()
        self.loginSegmentControl.selectedSegmentIndex = 0
        self.signupButton.layer.cornerRadius = 5
        self.signupButton.layer.masksToBounds = true
        self.changeInputViewUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        self.nameTextField.text = ""
        self.phoneTextField.text = ""
        self.errorLabel.text = ""
        self.navigationController?.isNavigationBarHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.passwordTextField.resignFirstResponder()
        self.emailTextField.resignFirstResponder()
    }
    
    //MARK:IBActions
    
    @IBAction func lockButtonAction(_ sender: UIButton) {
        if sender.tag == 0 {
            sender.tag = 1
            self.passwordTextField.isSecureTextEntry = false
            sender.setImage(UIImage(named: "unlock"), for: .normal)
        } else {
            sender.tag = 0
            self.passwordTextField.isSecureTextEntry = true
            sender.setImage(UIImage(named: "lock"), for: .normal)
        }
    }
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        self.changeInputViewUI()
    }
    
    @IBAction func signUpBtnAction(_ sender: UIButton) {
        if self.loginSegmentControl.selectedSegmentIndex == 0 {
            if isValidEmail(testStr: self.emailTextField.text!) || isValidPhoneNumber(value: self.emailTextField.text!) {
                self.login()
                }
            else { //Email or Phone number not valid.
                self.errorLabel.text = "Invalid Credentials"
                self.errorLabel.shake()
            }
        }else{
            if isValidEmail(testStr: self.emailTextField.text!) && isValidPhoneNumber(value: self.phoneTextField.text!) && self.nameTextField.text?.trimmingCharacters(in: .whitespaces) != "" && self.passwordTextField.text?.trimmingCharacters(in: .whitespaces) != "" {
                self.saveDataToCoreData()
            }else{
                self.errorLabel.text = "Invalid Credentials"
                self.errorLabel.shake()
            }
        }
    }
    
    func login() {
        self.fetchFromCoreData (loginField : self.emailTextField.text!) { (responseObj : [Any]?, error : NSError?) in
            if error == nil {
                if responseObj?.count == 0 { //New User case
                    self.errorLabel.text = "User doesn't exist"
                    self.errorLabel.shake()
                }
                for data in responseObj as! [NSManagedObject] {
                    let password = data.value(forKey: "password") as! String
                    let emailID = data.value(forKey: "emailID") as! String
                    let phoneNumber = data.value(forKey: "phoneNumber") as! String
                    if (password == self.passwordTextField.text) && (phoneNumber == self.emailTextField.text || emailID == self.emailTextField.text) {
                        self.errorLabel.text = ""
                        self.newUser = data // Existing user and valid credentials
                        self.showAlert(title: "Successfully logged In", message: "Yayy!", okAction : true)
                    }else { // Existing user but invalid password
                        self.errorLabel.text = "Invalid Password"
                        self.errorLabel.shake()
                    }
                }
            } else { // Error fetching
                self.showAlert(title: (error?.localizedDescription)!, message: "")
            }
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPhoneNumber(value: String) -> Bool {
        let PHONE_REGEX = "^\\d{10}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: value)
        return result
    }
    
    func changeInputViewUI() {
        if self.loginSegmentControl.selectedSegmentIndex == 0 {
            self.signupButton.setTitle("Login", for: .normal)
            self.emailTextField.placeholder = "* Email / Phone Number"
            self.nameTextField.isHidden = true
            self.phoneTextField.isHidden = true
            self.nameTextField.isEnabled = false
            self.phoneTextField.isEnabled = false
            UIView.animate(withDuration: 0.3) {
                self.inputViewHeightConstraint.constant = 106
                self.userInputView.frame = CGRect(x: 0, y: 120, width: self.view.frame.width, height: 106)
                self.userInputView.layoutIfNeeded()
            }
            
        }else {
            self.signupButton.setTitle("Sign Up", for: .normal)
            self.emailTextField.placeholder = "* Email ID"
            self.nameTextField.isHidden = false
            self.phoneTextField.isHidden = false
            self.nameTextField.isEnabled = true
            self.phoneTextField.isEnabled = true
            UIView.animate(withDuration: 0.3) {
                self.inputViewHeightConstraint.constant = 200
                self.userInputView.frame = CGRect(x: 0, y: 120, width: self.view.frame.width, height: 200)
                self.userInputView.layoutIfNeeded()
            }
            
        }
    }
    
    func showAlert(title:String,message:String, okAction : Bool? = nil)  {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
            if okAction != nil {
                let homeVC = HomeViewController(nibName : "HomeViewController", bundle : nil)
                homeVC.userData = self.newUser
                self.navigationController?.pushViewController(homeVC, animated: true)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK:Textfield Methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.errorLabel.text = ""
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return true
    }
    
    
}
