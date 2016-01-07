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
}

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    var type: SignupSectionType = .Login
    
    @IBOutlet weak var constraintContentWidth: NSLayoutConstraint!
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var constraintLoginHeight: NSLayoutConstraint!
    @IBOutlet weak var constraintSignUpHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonSignup: UIButton!
    
    var currentInput: UITextField?
    @IBOutlet weak var inputLoginEmail: UITextField!
    @IBOutlet weak var inputLoginPassword: UITextField!
    @IBOutlet weak var inputSignupEmail: UITextField!
    @IBOutlet weak var inputSignupPassword: UITextField!
    @IBOutlet weak var inputConfirmation: UITextField!
    
    var cancelEditing: Bool = false
    
    var keyboardDoneButtonView: UIToolbar = UIToolbar()
    
    var loginEmail: String?
    var loginPassword: String?
    var signupEmail: String?
    var signupPassword: String?
    var confirmation: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "close")
        
        keyboardDoneButtonView.sizeToFit()
        keyboardDoneButtonView.barStyle = UIBarStyle.Black
        keyboardDoneButtonView.tintColor = UIColor.whiteColor()
        let button: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: "dismissKeyboard")
        let close: UIBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: "endEditing")
        let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.setItems([close, flex, button], animated: true)
        for input: UITextField in [inputLoginEmail, inputLoginPassword, inputSignupEmail, inputSignupPassword, inputConfirmation] {
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
        self.contentView.layoutSubviews()
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
        if !show {
            height = 0
            if showHeader {
                height = 60
            }
        }
        
        constraint.constant = height
        self.constraintContentHeight.constant = self.constraintLoginHeight.constant + self.constraintSignUpHeight.constant
        
        if animated {
            self.view.setNeedsUpdateConstraints()
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
                self.contentView.layoutIfNeeded()
            }, completion: { (done) -> Void in
                self.scrollView.contentSize = CGSizeMake(self.constraintContentWidth.constant, self.constraintContentHeight.constant)
            })
        }
        else {
            self.view.layoutSubviews()
            self.contentView.layoutSubviews()
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
        self.refreshForType(true)
    }
    
    func refreshForType(animated: Bool) {
        if self.type == .Login {
            // show login; show signup header
            self.toggleSection(.Signup, show: false, showHeader: true, animated: false)
            self.toggleSection(.Login, show: true, showHeader: false, animated: animated)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log in", style: .Done, target: self, action: "validateFields")
        }
        else if self.type == .Signup {
            self.toggleSection(.Login, show: false, showHeader: true, animated: false)
            self.toggleSection(.Signup, show: true, showHeader: false, animated: animated)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign up", style: .Done, target: self, action: "validateFields")
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
    }
    
    func login() {
        PFUser.logInWithUsernameInBackground(self.loginEmail!, password: self.loginPassword!) { (user, error) -> Void in
            if user != nil {
                // login successful
                self.close()
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
                self.performSegueWithIdentifier("SignupToProfile", sender: nil)
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "SignupToProfile" {
            let controller: ProfileViewController = segue.destinationViewController as! ProfileViewController
            controller.isSignup = true
        }
    }
}
