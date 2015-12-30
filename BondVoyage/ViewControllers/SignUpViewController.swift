//
//  SignUpViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/30/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit

var kInputCellIdentifier = "InputCell"
let genders = ["Select gender", "Male", "Female", "Other"]

class SignUpViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var constraintBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var constraintContentWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintSignUpHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintProfileHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var currentInput: UITextField!
    @IBOutlet weak var inputEmail: UITextField!
    @IBOutlet weak var inputPassword: UITextField!
    @IBOutlet weak var inputConfirmation: UITextField!
    @IBOutlet weak var inputFirstName: UITextField!
    @IBOutlet weak var inputLastName: UITextField!
    @IBOutlet weak var inputGender: UITextField!
    @IBOutlet weak var inputBirthYear: UITextField!
    
    var cancelEditing: Bool = false
    
    var pickerGender: UIPickerView = UIPickerView()
    var pickerBirthYear: UIPickerView = UIPickerView()
    var keyboardDoneButtonView: UIToolbar = UIToolbar()
    
    var email: String?
    var password: String?
    var confirmation: String?
    var firstName: String?
    var lastName: String?
    var gender: String?
    var birthYear: Int?

    var currentYear: Int = 2016
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "close")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign up", style: .Done, target: self, action: "signUp")
        
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
        for input: UITextField in [inputEmail, inputPassword, inputConfirmation, inputFirstName, inputLastName, inputGender, inputBirthYear] {
            input.inputAccessoryView = keyboardDoneButtonView
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.inputEmail.placeholder = "Enter your email"
        self.inputPassword.placeholder = "Enter a new password"
        self.inputConfirmation.placeholder = "Enter password again"
        self.inputFirstName.placeholder = "Enter your first name"
        self.inputLastName.placeholder = "Enter your last name"
        self.inputGender.placeholder = "Select your gender"
        self.inputBirthYear.placeholder = "Select your birth year"
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.constraintContentWidth.constant = self.view.frame.size.width
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func signUp() {
        self.view.endEditing(true)
        print("Signing up with email \(self.email) password \(self.password) confirmation \(self.confirmation) name \(self.firstName) \(self.lastName) gender \(self.gender) year \(self.birthYear)")
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
        
        if textField == self.inputEmail {
            self.inputPassword.becomeFirstResponder()
            self.email = self.inputEmail.text
        }
        else if textField == self.inputPassword {
            self.inputConfirmation.becomeFirstResponder()
            self.password = self.inputPassword.text
        }
        else if textField == self.inputConfirmation {
            self.confirmation = self.inputConfirmation.text
            textField.resignFirstResponder()
            return true
        }
        else if textField == self.inputFirstName {
            self.inputLastName.becomeFirstResponder()
            self.firstName = self.inputFirstName.text
        }
        else if textField == self.inputLastName {
            self.inputGender.becomeFirstResponder()
            self.lastName = self.inputLastName.text
        }
        else if textField == self.inputGender {
            self.inputBirthYear.becomeFirstResponder()
            if self.inputGender.text != "Select gender" {
                self.gender = self.inputGender.text
            }
        }
        else if textField == self.inputBirthYear {
            if self.inputBirthYear.text != "Select your birth year" {
                self.birthYear = Int(self.inputBirthYear.text!)
            }
            textField.resignFirstResponder()
            return true
        }
        return false
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.currentInput = textField
        let view: UIView = self.currentInput.superview!
        var rect: CGRect = view.frame
        rect.origin.y = view.superview!.frame.origin.y
        self.scrollView.scrollRectToVisible(rect, animated: true)
        return true
    }

    func dismissKeyboard() {
        cancelEditing = false
        self.currentInput.resignFirstResponder()
    }
    
    func endEditing() {
        cancelEditing = true
        self.view.endEditing(true)
    }
    
    // MARK: - keyboard notifications
    func keyboardWillShow(n: NSNotification) {
        let size = n.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        self.constraintBottomOffset.constant = size!.height

        self.view.layoutIfNeeded()

        let view: UIView = self.currentInput.superview!
        var rect: CGRect = view.frame
        rect.origin.y = view.superview!.frame.origin.y
        self.scrollView.scrollRectToVisible(rect, animated: true)
    }
    
    func keyboardWillHide(n: NSNotification) {
        self.constraintBottomOffset.constant = 0
        self.view.layoutIfNeeded()
    }

}
