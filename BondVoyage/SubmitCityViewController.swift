//
//  SubmitCityViewController.swift
//  BondVoyage
//
//  Created by Tom Strissel on 11/3/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class SubmitCityViewController: UIViewController, UITextFieldDelegate {

    var selectedCity: String?
    
    @IBOutlet weak var inputCity: UITextField!
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputEmail: UITextField!

    @IBOutlet weak var constraintButton: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.inputCity.text = selectedCity
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapButton(sender: AnyObject?) {
        print("vote")
        self.submitCity()
    }
    
    
    func submitCity() {
        let name = self.inputName.text!
        let email = self.inputEmail.text!.lowercased()
        let city = self.inputCity.text!.capitalized
        
        if name.isEmpty {
            print("must have name")
            self.simpleAlert("More info needed", defaultMessage: "Please enter your name", error: nil, completion: nil)
            return
        }
        
        if !self.isValidEmail(email) {
            print("Invalid email")
            self.simpleAlert("More info needed", defaultMessage: "Please enter a valid email", error: nil, completion: nil)
            return
        }
        
        if city.isEmpty {
            print("Invalid city")
            self.simpleAlert("More info needed", defaultMessage: "Please enter the city you are in", error: nil, completion: nil)
            return
        }
        
        self.view.endEditing(true)

        let object = PFObject(className: "Suggestion")
        object.setValue(name, forKey: "name")
        object.setValue(email, forKey: "email")
        object.setValue("SuggestCity", forKey: "type")
        object.setValue(city, forKey:"message")
        object.saveInBackground { (success, error) in
            if let error = error as? NSError {
                self.simpleAlert("Could not suggest \(city)", defaultMessage: "We could not submit your suggestion for a new city to visit. Please try again", error: error)
            }
            else {
                self.simpleAlert("Thank you", message: "When BondVoyage arrives in \(city) we will be sure to let you know!", completion: {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK: - keyboard notifications
    func keyboardWillShow(_ n: Notification) {
        let size = (n.userInfo![UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size
        self.constraintButton.constant = size.height
        
        self.view.layoutIfNeeded()
    }
    
    func keyboardWillHide(_ n: Notification) {
        self.constraintButton.constant = 20
        self.view.layoutIfNeeded()
    }
    
}
