//
//  EditProfileViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/1/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse
import Photos
import AsyncImageView

class EditProfileViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var constraintBottomOffset: NSLayoutConstraint!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    var currentInput: UITextField?
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var inputBirthYear: UITextField!
    @IBOutlet weak var inputGender: UITextField!
    @IBOutlet weak var inputOccupation: UITextField!
    @IBOutlet weak var inputEducation: UITextField!
    @IBOutlet weak var inputLanguages: UITextField!
    @IBOutlet weak var inputWith: UITextField!
    
    @IBOutlet weak var imagePhoto: AsyncImageView!
    @IBOutlet weak var buttonPhoto: UIButton!
    @IBOutlet weak var buttonAbout: UIButton!
    
    @IBOutlet weak var inputCity: UITextField!
    
    var pickerBirthYear: UIPickerView = UIPickerView()
    var pickerGender: UIPickerView = UIPickerView()
    var pickerWith: UIPickerView = UIPickerView()
    
    var isSignup: Bool = false
    var selectedPhoto: UIImage?

    var name: String?
    var birthYear: Int?
    var occupation: String?
    var education: String?
    var languages: String?

    var currentYear: Int = 2016
    var keyboardDoneButtonView: UIToolbar = UIToolbar()
    var cancelEditing: Bool = false
    var gender: Gender?
    var group: Group?

    var genderOptions: [Gender] = [Gender.Male, Gender.Female, Gender.Other]
    var withOptions: [Group] = [.Solo, .SignificantOther, .Family, .Friends]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.isSignup {
            // comes from signing up
            self.navigationItem.hidesBackButton = true
        }
        self.title = "Edit Profile"
        self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()

        //self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .Plain, target: self, action: "logout")

        let date = Date()
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.year], from: date)
        currentYear = components.year!
        
        // pickers for age
        pickerBirthYear.delegate = self
        pickerBirthYear.dataSource = self
        self.inputBirthYear.inputView = pickerBirthYear

        // picker for gender
        pickerGender.delegate = self
        pickerGender.dataSource = self
        self.inputGender.inputView = pickerGender

        // picker for with
        pickerWith.delegate = self
        pickerWith.dataSource = self
        self.inputWith.inputView = pickerWith
        
        keyboardDoneButtonView.sizeToFit()
        keyboardDoneButtonView.barStyle = UIBarStyle.black
        keyboardDoneButtonView.tintColor = UIColor.white
        let button: UIBarButtonItem = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.done, target: self, action: #selector(EditProfileViewController.dismissKeyboard))
        let close: UIBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.done, target: self, action: #selector(EditProfileViewController.endEditing))
        let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.setItems([close, flex, button], animated: true)
        for input: UITextField in [inputName, inputGender, inputBirthYear, inputOccupation, inputEducation, inputLanguages, inputWith] {
            input.inputAccessoryView = keyboardDoneButtonView
        }
        
        if PFUser.current() != nil {
            let user: PFUser = PFUser.current() as! User
            user.fetchInBackground(block: { (result, error) -> Void in
                if result != nil {
                    if let photoURL: String = result!.value(forKey: "photoUrl") as? String {
                        self.imagePhoto.setValue(URL(string:photoURL), forKey: "imageURL")
                        //self.imagePhoto.imageURL = NSURL(string: photoURL)
                    }
                    else {
                        self.imagePhoto.image = UIImage(named: "profile")
                    }
                }
            })
                
            if let firstName: String = user.object(forKey: "firstName") as? String {
                self.inputName.text = firstName
            }
            if let birthYear: Int = user.object(forKey: "birthYear") as? Int {
                self.inputBirthYear.text = "\(birthYear)"
            }
            if let occupation: String = user.object(forKey: "occupation") as? String {
                self.inputOccupation.text = occupation
            }
            if let education: String = user.object(forKey: "education") as? String {
                self.inputEducation.text = education
            }
            if let languages: String = user.object(forKey: "languages") as? String {
                self.inputLanguages.text = languages
            }
            if let gender: String = user.object(forKey: "gender") as? String {
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
            
            if let city = user.object(forKey: "city") as? String, !city.isEmpty {
                self.inputCity.text = city
            }
        }
        
        self.imagePhoto.layer.cornerRadius = self.imagePhoto.frame.size.width / 2
        self.imagePhoto.layer.borderColor = Constants.lightBlueColor().cgColor
        self.imagePhoto.layer.borderWidth = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EditProfileViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func logout() {
        UserService.logout()
    }
    
    // MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerGender {
            return 4 // select, MFO
        }
        else if pickerView == self.pickerWith {
            return 5
        }
        return 80 // years
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.pickerGender {
            print("row: \(row)")
            print("genders \(genderOptions)")
            if row == 0 {
                return "Select a gender"
            }
            return genderOptions[row-1].rawValue
        }
        else if pickerView == self.pickerWith {
            if row == 0 {
                return "Select one"
            }
            else if withOptions[row-1] == .SignificantOther {
                return "Significant other"
            }
            return withOptions[row-1].rawValue
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
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.pickerGender {
            if row == 0 {
                self.gender = nil
            }
            else {
                self.gender = genderOptions[row-1]
                self.inputGender.text = self.gender?.rawValue
            }
        }
        else if pickerView == self.pickerWith {
            if row == 0 {
                self.group = nil
            }
            else {
                self.group = withOptions[row-1]
                if withOptions[row-1] == .SignificantOther {
                    self.inputWith.text = "Significant other"
                }
                else {
                    self.inputWith.text = self.group?.rawValue
                }
            }
        }
        else {
            self.birthYear = currentYear - row
            self.inputBirthYear.text = "\(self.birthYear!)"
        }
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if cancelEditing {
            return true
        }
        
        self.validateFields(textField)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.inputCity {
            self.selectCity()
            return false
        }
        
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
    func keyboardWillShow(_ n: Notification) {
        let size = (n.userInfo![UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size
        self.constraintBottomOffset.constant = size.height
        
        self.view.layoutIfNeeded()
    }
    
    func keyboardWillHide(_ n: Notification) {
        self.constraintBottomOffset.constant = 0
        self.view.layoutIfNeeded()
    }

    func validateFields(_ input: UITextField) {
        cancelEditing = true
        self.view.endEditing(true)
        self.name = self.inputName.text
        self.occupation = self.inputOccupation.text
        self.education = self.inputEducation.text
        self.languages = self.inputLanguages.text
        if self.inputBirthYear.text != "Select your birth year" {
            self.birthYear = Int(self.inputBirthYear.text!)
        }

        self.updateProfile()
    }

    func updateProfile() {
        let user = PFUser.current()
        if user == nil {
            self.simpleAlert("Could not update profile", message: "Please log in or sign up")
            return
        }
        
        if self.name != nil {
            user!.setValue(self.name, forKey: "firstName")
        }
        
        if self.occupation != nil {
            user!.setValue(self.occupation, forKey: "occupation")
        }

        if self.education != nil {
            user!.setValue(self.education, forKey: "education")
        }

        if self.languages != nil {
            user!.setValue(self.languages, forKey: "languages")
        }

        if self.birthYear != nil {
            user!.setValue(self.birthYear, forKey: "birthYear")
        }
        
        if self.gender != nil {
            user!.setValue(self.gender!.rawValue.lowercased(), forKey: "gender")
        }
        
        if self.group != nil {
            user!.setValue(self.group!.rawValue, forKey: "group")
        }
        
        user!.saveInBackground(block: { (success, error) -> Void in
            if success {
                if self.selectedPhoto != nil {
                    let data: Data = UIImageJPEGRepresentation(self.selectedPhoto!, 0.8)!
                    let file: PFFile = PFFile(name: "profile.jpg", data: data)!
                    user!.setObject(file, forKey: "photo")
                    file.saveInBackground(block: { (success, error) -> Void in
                        user!.setObject(file.url!, forKey: "photoUrl")
                        user!.saveInBackground()
                    })
                }

                self.appDelegate().logUser()
                NotificationCenter.default.post(name: Notification.Name(rawValue: "profile:updated"), object: nil)
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
    func addPhoto(_ sender: UIButton) {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.black
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) -> Void in
                let cameraStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
                if cameraStatus == .denied {
                    self.warnForCameraAccess()
                }
                else {
                    // go to camera
                    picker.sourceType = .camera
                    self.present(picker, animated: true, completion: nil)
                }
            }))
        }
        alert.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { (action) -> Void in
            let libraryStatus = PHPhotoLibrary.authorizationStatus()
            if libraryStatus == .denied {
                self.warnForLibraryAccess()
            }
            else {
                // go to library
                picker.sourceType = .photoLibrary
                self.present(picker, animated: true, completion: nil)
            }
        }))
        if let fbid = PFUser.current()?.value(forKey: "facebook_id") {
            alert.addAction(UIAlertAction(title: "Facebook", style: .default, handler: { (action) -> Void in
                let url = "https://graph.facebook.com/v2.5/\(fbid)/picture?type=large&return_ssl_resources=1&width=1125"
                PFUser.current()?.setObject(url, forKey: "photoUrl")
                self.imagePhoto.setValue(URL(string:url), forKey: "imageURL")
                //self.imagePhoto.imageURL = NSURL(string: url)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    
    func warnForLibraryAccess() {
        let message: String = "WeTrain needs photo library access to load your profile picture. Would you like to go to your phone settings to enable the photo library?"
        let alert: UIAlertController = UIAlertController(title: "Could not access photos", message: message, preferredStyle: .alert)
        alert.view.tintColor = UIColor.black
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func warnForCameraAccess() {
        let message: String = "WeTrain needs camera access to take your profile photo. Would you like to go to your phone settings to enable the camera?"
        let alert: UIAlertController = UIAlertController(title: "Could not access camera", message: message, preferredStyle: .alert)
        alert.view.tintColor = UIColor.black
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) -> Void in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.imagePhoto.image = image
        self.selectedPhoto = image
        
        let data: Data = UIImageJPEGRepresentation(self.selectedPhoto!, 0.8)!
        let file: PFFile = PFFile(name: "profile.jpg", data: data)!
        PFUser.current()!.setObject(file, forKey: "photo")
        file.saveInBackground(block: { (success, error) -> Void in
            if success {
                PFUser.current()!.setObject(file.url!, forKey: "photoUrl")
                self.imagePhoto.setValue(URL(string:file.url!), forKey: "imageURL")
                //self.imagePhoto.imageURL = NSURL(string:file.url!)
                PFUser.current()!.saveInBackground()
            }
            picker.dismiss(animated: true, completion: nil)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: Interests
    @IBAction func didClickButton(_ sender: UIButton) {
        if sender == self.buttonPhoto {
            self.addPhoto(sender)
        }
        else if sender == self.buttonAbout {
            self.performSegue(withIdentifier: "toAboutMe", sender: self)
        }
    }
}

extension EditProfileViewController: CityViewDelegate {
    func selectCity() {
        let storyboard = UIStoryboard(name: "City", bundle: nil)
        if let controller = storyboard.instantiateInitialViewController() as? CityViewController {
            controller.delegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }

    func didFinishSelectCity() {
        self.dismiss(animated: true, completion: nil)
    }
}
