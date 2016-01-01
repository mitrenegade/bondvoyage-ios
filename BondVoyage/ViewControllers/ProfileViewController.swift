//
//  ProfileViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/1/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class ProfileViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate  {
    @IBOutlet weak var constraintContentWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintProfileHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomOffset: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    var currentInput: UITextField?
    @IBOutlet weak var inputFirstName: UITextField!
    @IBOutlet weak var inputLastName: UITextField!
    @IBOutlet weak var inputGender: UITextField!
    @IBOutlet weak var inputBirthYear: UITextField!

    var pickerGender: UIPickerView = UIPickerView()
    var pickerBirthYear: UIPickerView = UIPickerView()
    
    var isSignup: Bool = false

    var firstName: String?
    var lastName: String?
    var gender: String?
    var birthYear: Int?

    var currentYear: Int = 2016
    var keyboardDoneButtonView: UIToolbar = UIToolbar()
    var cancelEditing: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.isSignup {
            // comes from signing up
            self.navigationItem.hidesBackButton = true
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: "validateFields")
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year], fromDate: date)
        currentYear = components.year
        
        // pickers for age and gender
        pickerGender.delegate = self
        pickerGender.dataSource = self
        self.inputGender.inputView = pickerGender
        pickerBirthYear.delegate = self
        pickerBirthYear.dataSource = self
        self.inputBirthYear.inputView = pickerBirthYear
                
        keyboardDoneButtonView.sizeToFit()
        keyboardDoneButtonView.barStyle = UIBarStyle.Black
        keyboardDoneButtonView.tintColor = UIColor.whiteColor()
        let button: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: "dismissKeyboard")
        let close: UIBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: "endEditing")
        let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.setItems([close, flex, button], animated: true)
        for input: UITextField in [inputFirstName, inputLastName, inputGender, inputBirthYear] {
            input.inputAccessoryView = keyboardDoneButtonView
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        if PFUser.currentUser() != nil {
            let user: PFUser = PFUser.currentUser()!
            if let firstName: String = user.objectForKey("firstName") as? String{
                self.inputFirstName.text = firstName
            }
            if let lastName: String = user.objectForKey("lastName") as? String{
                self.inputLastName.text = lastName
            }
            if let gender: String = user.objectForKey("gender") as? String{
                self.inputGender.text = gender
            }
            if let birthYear: Int = user.objectForKey("birthYear") as? Int{
                self.inputBirthYear.text = "\(birthYear)"
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.constraintContentWidth.constant = self.view.frame.size.width
        self.scrollView.contentSize = CGSizeMake(self.constraintContentWidth.constant, self.constraintContentHeight.constant)
    }

    func close() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerGender {
            return 4 // select, MFO
        }
        return 80 // years
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.pickerGender {
            print("row: \(row)")
            print("genders \(genders)")
            return genders[row]
        }
        else {
            if row == 0 {
                return "Select your birth year"
            }
            else {
                let year = currentYear - row
                return "\(year)"
            }
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.pickerGender {
            if row == 0 {
                self.gender = nil
            }
            else {
                self.gender = genders[row]
                self.inputGender.text = self.gender
            }
        }
        else {
            self.birthYear = currentYear - row
            self.inputBirthYear.text = "\(self.birthYear!)"
        }
    }

    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if cancelEditing {
            return true
        }
        
        if textField == self.inputFirstName {
            self.inputLastName.becomeFirstResponder()
        }
        else if textField == self.inputLastName {
            self.inputGender.becomeFirstResponder()
        }
        else if textField == self.inputGender {
            self.inputBirthYear.becomeFirstResponder()
        }
        else if textField == self.inputBirthYear {
            textField.resignFirstResponder()
            return true
        }
        return false
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.currentInput = textField
        let view: UIView = self.currentInput!.superview!
        var rect: CGRect = view.frame
        rect.origin.y = view.superview!.frame.origin.y
        self.scrollView.scrollRectToVisible(rect, animated: true)
        return true
    }
    
    func dismissKeyboard() {
        cancelEditing = false
        self.currentInput!.resignFirstResponder()
    }
    
    func endEditing() {
        cancelEditing = true
        self.view.endEditing(true)
    }
    
    // MARK: - keyboard notifications
    func keyboardWillShow(n: NSNotification) {
        let size = n.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        self.constraintBottomOffset.constant = size!.height + 20
        
        self.view.layoutIfNeeded()
        
        let view: UIView = self.currentInput!.superview!
        var rect: CGRect = view.frame
        rect.origin.y = view.superview!.frame.origin.y
        self.scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    func keyboardWillHide(n: NSNotification) {
        self.constraintBottomOffset.constant = 0
        self.view.layoutIfNeeded()
    }

    func validateFields() {
        cancelEditing = true
        self.view.endEditing(true)
        self.firstName = self.inputFirstName.text
        self.lastName = self.inputLastName.text
        if self.inputGender.text != "Select gender" {
            self.gender = self.inputGender.text
        }
        if self.inputBirthYear.text != "Select your birth year" {
            self.birthYear = Int(self.inputBirthYear.text!)
        }
        

        self.updateProfile()
    }

    func updateProfile() {
        let user = PFUser.currentUser()
        if user == nil {
            self.simpleAlert("Could not update profile", message: "Please log in or sign up")
            return
        }
        
        if self.firstName != nil {
            user!.setValue(self.firstName, forKey: "firstName")
        }
        
        if self.lastName != nil {
            user!.setValue(self.lastName, forKey: "lastName")
        }
        
        if self.gender != nil {
            user!.setValue(self.gender, forKey: "gender")
        }
        
        if self.birthYear != nil {
            user!.setValue(self.birthYear, forKey: "birthYear")
        }
        
        user?.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                self.close()
            }
            else {
                var message = "There was an error updating your profile."
                if let msg = error!.localizedDescription as? String {
                    message = msg
                }
                self.simpleAlert("Could not update profile", message: message, completion: nil)
            }
        })
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
