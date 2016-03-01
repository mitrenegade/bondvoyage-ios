//
//  ProfileViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/1/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse
import Photos
import AsyncImageView

class ProfileViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var constraintBottomOffset: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    var currentInput: UITextField?
    @IBOutlet weak var inputFirstName: UITextField!
    @IBOutlet weak var inputLastName: UITextField!
    @IBOutlet weak var inputBirthYear: UITextField!
    @IBOutlet weak var inputGender: UITextField!

    @IBOutlet weak var imagePhoto: AsyncImageView!
    @IBOutlet weak var buttonPhoto: UIButton!
    @IBOutlet weak var buttonAbout: UIButton!
    @IBOutlet weak var buttonPreview: UIButton!
    
    var pickerBirthYear: UIPickerView = UIPickerView()
    var pickerGender: UIPickerView = UIPickerView()
    
    var isSignup: Bool = false
    var selectedPhoto: UIImage?

    var firstName: String?
    var lastName: String?
    var birthYear: Int?

    var currentYear: Int = 2016
    var keyboardDoneButtonView: UIToolbar = UIToolbar()
    var cancelEditing: Bool = false
    var gender: Gender?

    var genderOptions: [Gender] = [Gender.Male, Gender.Female, Gender.Other]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.isSignup {
            // comes from signing up
            self.navigationItem.hidesBackButton = true
        }
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Done, target: self, action: "validateFields")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "close")

        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year], fromDate: date)
        currentYear = components.year
        
        // pickers for age
        pickerBirthYear.delegate = self
        pickerBirthYear.dataSource = self
        self.inputBirthYear.inputView = pickerBirthYear

        // picker for gender
        pickerGender.delegate = self
        pickerGender.dataSource = self
        self.inputGender.inputView = pickerGender

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
        
        if PFUser.currentUser() != nil {
            let user: PFUser = PFUser.currentUser()!
            user.fetchInBackgroundWithBlock({ (result, error) -> Void in
                if result != nil {
                    if let photoURL: String = result!.valueForKey("photoUrl") as? String {
                        self.imagePhoto.imageURL = NSURL(string: photoURL)
                    }
                    else {
                        self.imagePhoto.image = UIImage(named: "profile-icon")
                    }
                }
            })
                
            if let firstName: String = user.objectForKey("firstName") as? String{
                self.inputFirstName.text = firstName
            }
            if let lastName: String = user.objectForKey("lastName") as? String{
                self.inputLastName.text = lastName
            }
            if let birthYear: Int = user.objectForKey("birthYear") as? Int{
                self.inputBirthYear.text = "\(birthYear)"
            }
            if let gender: String = user.objectForKey("gender") as? String{
                if gender == "male" {
                    self.gender = .Male
                }
                if gender == "female" {
                    self.gender = .Female
                }
                if gender == "Male" {
                    self.gender = .Other
                }
                self.inputGender.text = self.gender?.rawValue
            }
        }
        
        self.imagePhoto.layer.cornerRadius = self.imagePhoto.frame.size.width / 2
        self.imagePhoto.layer.borderColor = Constants.lightBlueColor().CGColor
        self.imagePhoto.layer.borderWidth = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func close() {
        self.navigationController?.popViewControllerAnimated(true)
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
            print("genders \(genderOptions)")
            if row == 0 {
                return "Select a gender"
            }
            return genderOptions[row-1].rawValue
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
                self.gender = genderOptions[row-1]
                self.inputGender.text = self.gender?.rawValue
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
            self.inputBirthYear.becomeFirstResponder()
        }
        else if textField == self.inputBirthYear {
            self.inputGender.becomeFirstResponder()
        }
        else if textField == self.inputGender {
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
        self.constraintBottomOffset.constant = size!.height
        
        self.view.layoutIfNeeded()
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
        
        if self.birthYear != nil {
            user!.setValue(self.birthYear, forKey: "birthYear")
        }
        
        if self.gender != nil {
            user!.setValue(self.gender!.rawValue.lowercaseString, forKey: "gender")
        }
        
        
        user!.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                if self.selectedPhoto != nil {
                    let data: NSData = UIImageJPEGRepresentation(self.selectedPhoto!, 0.8)!
                    let file: PFFile = PFFile(name: "profile.jpg", data: data)!
                    user!.setObject(file, forKey: "photo")
                    file.saveInBackgroundWithBlock({ (success, error) -> Void in
                        user!.setObject(file.url!, forKey: "photoUrl")
                        user!.saveInBackground()
                    })
                }

                self.appDelegate().logUser()
                self.close()
            }
            else {
                var message = "There was an error updating your profile."
                if error?.localizedDescription != nil {
                    message = error!.localizedDescription
                }
                self.simpleAlert("Could not update profile", message: message, completion: nil)
            }
        })
    }
    
    // MARK: - Photo
    func addPhoto(sender: UIButton) {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.view.tintColor = UIColor.blackColor()
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action) -> Void in
                let cameraStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
                if cameraStatus == .Denied {
                    self.warnForCameraAccess()
                }
                else {
                    // go to camera
                    picker.sourceType = .Camera
                    self.presentViewController(picker, animated: true, completion: nil)
                }
            }))
        }
        alert.addAction(UIAlertAction(title: "Photo library", style: .Default, handler: { (action) -> Void in
            let libraryStatus = PHPhotoLibrary.authorizationStatus()
            if libraryStatus == .Denied {
                self.warnForLibraryAccess()
            }
            else {
                // go to library
                picker.sourceType = .PhotoLibrary
                self.presentViewController(picker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    func warnForLibraryAccess() {
        let message: String = "WeTrain needs photo library access to load your profile picture. Would you like to go to your phone settings to enable the photo library?"
        let alert: UIAlertController = UIAlertController(title: "Could not access photos", message: message, preferredStyle: .Alert)
        alert.view.tintColor = UIColor.blackColor()
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func warnForCameraAccess() {
        let message: String = "WeTrain needs camera access to take your profile photo. Would you like to go to your phone settings to enable the camera?"
        let alert: UIAlertController = UIAlertController(title: "Could not access camera", message: message, preferredStyle: .Alert)
        alert.view.tintColor = UIColor.blackColor()
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.imagePhoto.image = image
        self.imagePhoto.imageURL = nil
        self.selectedPhoto = image
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: Interests
    @IBAction func didClickButton(sender: UIButton) {
        if sender == self.buttonPhoto {
            self.addPhoto(sender)
        }
        else if sender == self.buttonAbout {
            self.performSegueWithIdentifier("toAboutMe", sender: self)
        }
        else if sender == self.buttonPreview {
            self.previewProfile()
        }
    }
    
    func previewProfile() {
        let user: PFUser = PFUser.currentUser()!
        let controller: UserDetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("UserDetailsViewController") as! UserDetailsViewController
        controller.selectedUser = user
        controller.title = "My Profile"
        self.navigationController?.pushViewController(controller, animated: true)
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
