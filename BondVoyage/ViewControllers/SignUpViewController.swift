//
//  SignUpViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/30/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit
import Parse

var kInputCellIdentifier = "InputCell"
let genders = ["Select gender", "Male", "Female", "Other"]

enum SignupSectionType: Int {
    case Login
    case Signup
    case ProfileOnly
}

class SignUpViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    var type: SignupSectionType = .ProfileOnly
    
    @IBOutlet weak var constraintContentWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var constraintLoginHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintSignUpHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintProfileHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonSignup: UIButton!
    @IBOutlet weak var buttonProfile: UIButton!
    
    var currentInput: UITextField?
    @IBOutlet weak var inputLoginEmail: UITextField!
    @IBOutlet weak var inputLoginPassword: UITextField!
    @IBOutlet weak var inputSignupEmail: UITextField!
    @IBOutlet weak var inputSignupPassword: UITextField!
    @IBOutlet weak var inputConfirmation: UITextField!
    @IBOutlet weak var inputFirstName: UITextField!
    @IBOutlet weak var inputLastName: UITextField!
    @IBOutlet weak var inputGender: UITextField!
    @IBOutlet weak var inputBirthYear: UITextField!
    
    var cancelEditing: Bool = false
    
    var pickerGender: UIPickerView = UIPickerView()
    var pickerBirthYear: UIPickerView = UIPickerView()
    var keyboardDoneButtonView: UIToolbar = UIToolbar()
    
    var loginEmail: String?
    var loginPassword: String?
    var signupEmail: String?
    var signupPassword: String?
    var confirmation: String?
    var firstName: String?
    var lastName: String?
    var gender: String?
    var birthYear: Int?

    var currentYear: Int = 2016
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "close")
        
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
        for input: UITextField in [inputLoginEmail, inputLoginPassword, inputSignupEmail, inputSignupPassword, inputConfirmation, inputFirstName, inputLastName, inputGender, inputBirthYear] {
            input.inputAccessoryView = keyboardDoneButtonView
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // initial constraints
        self.refreshForType(false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.constraintContentWidth.constant = self.view.frame.size.width
        self.scrollView.contentSize = CGSizeMake(self.constraintContentWidth.constant, self.constraintContentHeight.constant)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func toggleSection(section: SignupSectionType, show: Bool, showHeader: Bool, animated: Bool) {
        // showHeader is only used if show = false
        
        var height: CGFloat = 0
        var constraint: NSLayoutConstraint = constraintLoginHeight
        if section == .Login {
            // login
            height = 168
            constraint = constraintLoginHeight
        }
        else if section == .Signup {
            // signup
            height = 216
            constraint = constraintSignUpHeight
        }
        else if section == .ProfileOnly {
            // profile
            height = 264
            constraint = constraintProfileHeight
        }

        if !show {
            height = 0
            if showHeader {
                height = 60
            }
        }
        
        constraint.constant = height
        self.constraintContentHeight.constant = self.constraintLoginHeight.constant + self.constraintSignUpHeight.constant + self.constraintProfileHeight.constant
        self.view.setNeedsUpdateConstraints()
        
        if animated {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
            }, completion: { (done) -> Void in
                self.scrollView.contentSize = CGSizeMake(self.constraintContentWidth.constant, self.constraintContentHeight.constant)
            })
        }
        else {
            self.scrollView.contentSize = CGSizeMake(self.constraintContentWidth.constant, self.constraintContentHeight.constant)
        }
    }
    
    
    @IBAction func didClickButton(sender: UIButton) {
        // toggles login/signup sections
        if sender == self.buttonLogin {
            self.type = .Login
        }
        else if sender == self.buttonSignup {
            self.type = .Signup
        }
        else if sender == self.buttonProfile {
            self.type = .ProfileOnly
        }
        self.refreshForType(true)
    }
    
    func refreshForType(animated: Bool) {
        if self.type == .Login {
            // show login; show signup header
            self.toggleSection(.Signup, show: false, showHeader: true, animated: false)
            self.toggleSection(.ProfileOnly, show: false, showHeader: false, animated: false)
            self.toggleSection(.Login, show: true, showHeader: false, animated: animated)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .Done, target: self, action: "validateFields")
        }
        else if self.type == .Signup {
            self.toggleSection(.Login, show: false, showHeader: true, animated: false)
            self.toggleSection(.ProfileOnly, show: false, showHeader: false, animated: false)
            self.toggleSection(.Signup, show: true, showHeader: false, animated: animated)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign up", style: .Done, target: self, action: "validateFields")
        }
        else if self.type == .ProfileOnly {
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
            self.toggleSection(.Login, show: false, showHeader: false, animated: false)
            self.toggleSection(.Signup, show: false, showHeader: false, animated: false)
            self.toggleSection(.ProfileOnly, show: true, showHeader: false, animated: animated)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .Done, target: self, action: "validateFields")
        }
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
        
        if textField == self.inputLoginEmail {
            self.inputLoginPassword.becomeFirstResponder()
        }
        else if textField == self.inputLoginPassword {
            textField.resignFirstResponder()
            return true
        }
        else if textField == self.inputSignupEmail {
            self.inputSignupPassword.becomeFirstResponder()
        }
        else if textField == self.inputSignupPassword {
            self.inputConfirmation.becomeFirstResponder()
        }
        else if textField == self.inputConfirmation {
            textField.resignFirstResponder()
            return true
        }
        else if textField == self.inputFirstName {
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
        self.loginEmail = self.inputLoginEmail.text
        self.loginPassword = self.inputLoginPassword.text
        self.signupEmail = self.inputSignupEmail.text
        self.signupPassword = self.inputSignupPassword.text
        self.confirmation = self.inputConfirmation.text
        self.firstName = self.inputFirstName.text
        self.lastName = self.inputLastName.text
        if self.inputGender.text != "Select gender" {
            self.gender = self.inputGender.text
        }
        if self.inputBirthYear.text != "Select your birth year" {
            self.birthYear = Int(self.inputBirthYear.text!)
        }

        print("Signing up with email \(self.signupEmail) password \(self.signupPassword) confirmation \(self.confirmation) name \(self.firstName) \(self.lastName) gender \(self.gender) year \(self.birthYear)")
        
        if self.type == .Login {
            if self.loginEmail?.characters.count == 0 {
                self.simpleAlert("Please enter your login email", message: nil)
                return
            }
            if self.loginPassword?.characters.count == 0 {
                self.simpleAlert("Please your password", message: nil)
                return
            }
            
            self.login()
        }
        else if self.type == .Signup {
            if self.signupEmail?.characters.count == 0 {
                self.simpleAlert("Please enter your email as a username", message: nil)
                return
            }
            if !self.isValidEmail(self.signupEmail!) {
                self.simpleAlert("Please enter a valid email address", message: nil)
                return
            }
            if self.signupPassword?.characters.count == 0 {
                self.simpleAlert("Please enter a password", message: nil)
                return
            }
            if self.confirmation?.characters.count == 0 {
                self.simpleAlert("Please enter a password confirmation", message: nil)
                return
            }
            if self.confirmation != self.signupPassword {
                self.simpleAlert("Please make sure password matches confirmation", message: nil)
                return
            }

            self.signUp()
        }
        else if self.type == .ProfileOnly {
            self.updateProfile()
        }
    }
    
    func login() {
        PFUser.logInWithUsernameInBackground(self.loginEmail!, password: self.loginPassword!) { (user, error) -> Void in
            if user != nil {
                // login successful
                self.type = .ProfileOnly
                self.refreshForType(true)
            }
            else {
                self.simpleAlert("Invalid login", defaultMessage: "There was an issue logging you in.", error: error)
            }
        }
    }
    
    func signUp() {
        let user = PFUser()
        user.username = self.signupEmail!
        user.email = self.signupEmail!
        user.password = self.signupPassword!
        user.signUpInBackgroundWithBlock { (success, error) -> Void in
            if success {
                print("User signed up successfully")
                self.type = .ProfileOnly
                self.refreshForType(true)
            }
            else {
                print("Error signing up")
                var message = "There was an error signing up as a new user."
                if let msg = error!.localizedDescription as? String {
                    message = msg
                }
                self.simpleAlert("Could not sign up", message: message, completion: nil)
            }
        }
    }
    
    func updateProfile() {
        let user = PFUser.currentUser()
        if user == nil {
            self.simpleAlert("Could not update profile", message: "Please log in or sign up")
            self.type = .Login
            self.refreshForType(true)
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
}
