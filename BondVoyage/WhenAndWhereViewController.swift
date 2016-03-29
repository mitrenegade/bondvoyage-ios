//
//  WhenAndWhereViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 3/28/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class WhenAndWhereViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var viewWhere: UIView!
    @IBOutlet weak var viewWhen: UIView!
    @IBOutlet weak var viewAboutMe: UIView!
    @IBOutlet weak var viewWho: UIView!
    @IBOutlet weak var viewAges: UIView!
    
    @IBOutlet weak var inputWhere: UITextField!
    @IBOutlet weak var inputWhen: UITextField!
    @IBOutlet weak var inputAboutMe: UITextField!
    var currentInput: UITextField?
    
    @IBOutlet weak var tableViewWho: UITableView!
    @IBOutlet weak var constraintTableViewHeight: NSLayoutConstraint!
    var aboutSelf: VoyagerType?
    var selectedTypes: [Bool] = [false, false, false, false]
    
    @IBOutlet weak var ageFilterView: AgeRangeFilterView!
    
    var pickerWhere: UIPickerView = UIPickerView()
    var pickerWhen: UIPickerView = UIPickerView()
    var pickerMe: UIPickerView = UIPickerView()
    
    var category: CATEGORY?
    var currentLocation: CLLocation?
    var selectedActivities: [PFObject]?
    
    let ROW_HEIGHT: CGFloat = 44
    let PERSON_TYPES_DESC = ["New to the city", "Local to the city", "On leisure", "Traveling for business"]
    let PERSON_TYPES: [VoyagerType] = [.NewToCity, .Local, .Leisure, .Business]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for view: UIView in [viewWhere, viewWhen, viewAboutMe, viewWho, viewAges] {
            view.backgroundColor = UIColor.clearColor()
        }

        pickerWhere.delegate = self
        pickerWhen.delegate = self
        pickerMe.delegate = self
        inputWhere.inputView = pickerWhere
        inputWhen.inputView = pickerWhen
        inputAboutMe.inputView = pickerMe

        // location is always Boston
        self.currentLocation = CLLocation(latitude: BOSTON_LAT, longitude: BOSTON_LON)

        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        keyboardDoneButtonView.barStyle = UIBarStyle.Black
        keyboardDoneButtonView.tintColor = UIColor.whiteColor()
        let close: UIBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: "endEditing")
        let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.setItems([flex, close], animated: true)
        for input: UITextField in [inputWhere, inputWhen, inputAboutMe] {
            input.inputAccessoryView = keyboardDoneButtonView
        }

        self.ageFilterView.configure(RANGE_AGE_MIN, maxAge: RANGE_AGE_MAX, lower: RANGE_AGE_MIN, upper: RANGE_AGE_MAX)
        self.ageFilterView.label.textColor = UIColor.blackColor()
        
        self.constraintTableViewHeight.constant = ROW_HEIGHT * CGFloat(PERSON_TYPES.count)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Go", style: .Plain, target: self, action: "createActivity")
    }
    
    func createActivity() {
        self.navigationItem.rightBarButtonItem?.enabled = false
        // validate
        var aboutSelf: String? = self.inputAboutMe.text
        if self.inputAboutMe.text != nil && self.inputAboutMe.text!.isEmpty {
            aboutSelf = nil
        }
        
        var aboutOthers = [VoyagerType]()
        for var i = 0; i < self.selectedTypes.count; i++ {
            if self.selectedTypes[i] {
                aboutOthers.append(PERSON_TYPES[i])
            }
        }
        ActivityRequest.createActivity([self.category!.rawValue], location: self.currentLocation!, locationString: "Boston", aboutSelf: aboutSelf, aboutOthers:aboutOthers ) { (result, error) -> Void in
            if error != nil {
                self.navigationItem.rightBarButtonItem?.enabled = true
                print("Error: \(error)")
                
                print("We could not create an activity for you but you can still browse existing ones.")
            }
            else {
                print("result: \(result)")
                self.requestActivities()
            }
        }
    }
    
    func requestActivities() {
        let cat: [String] = [self.category!.rawValue]
        ActivityRequest.queryActivities(nil, joining: false, categories: cat, location: self.currentLocation, distance: Double(RANGE_DISTANCE_MAX)) { (results, error) -> Void in
            self.navigationItem.rightBarButtonItem?.enabled = true
            if results != nil {
                if results!.count > 0 {
                    self.selectedActivities = results
                    self.performSegueWithIdentifier("GoToInvite", sender: nil)
                }
                else {
                    // no results, no error
                    var message = "There is no one interested in \(CategoryFactory.categoryReadableString(self.category!)) near you."
                    if PFUser.currentUser() != nil {
                        message = "\(message) For the next hour, other people will be able to search for you and invite you to bond."
                    }
                    
                    self.simpleAlert("No activities nearby", message: message, completion: { () -> Void in
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    })
                }
            }
            else {
                if error != nil && error!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                        PFUser.logOut()
                        NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
                    })
                    return
                }
                let message = "There was a problem loading matches. Please try again"
                self.simpleAlert("Could not select category", defaultMessage: message, error: error)
            }
        }
    }
    
    // MARK: UITableViewDatasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PERSON_TYPES.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ROW_HEIGHT
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonTypeCell", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont(name: "AvenirNext-Regular", size: 14)
        cell.textLabel?.text = PERSON_TYPES_DESC[indexPath.row]
        
        cell.backgroundColor = UIColor.clearColor()
        
        if self.selectedTypes[indexPath.row] {
            cell.contentView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.25)
            cell.textLabel?.textColor = UIColor.blackColor()
        }
        else {
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.textLabel?.textColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
        }
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableViewWho.deselectRowAtIndexPath(indexPath, animated: false)
        selectedTypes[indexPath.row] = !selectedTypes[indexPath.row]
        self.tableViewWho.reloadData()
    }

    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerWhere || pickerView == self.pickerWhen {
            return 1
        }
        else if pickerView == self.pickerMe {
            return PERSON_TYPES.count + 1
        }
        return 0
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.pickerWhere {
            return "Boston"
        }
        if pickerView == self.pickerWhen {
            return "Now"
        }
        if pickerView == self.pickerMe {
            if row == 0 {
                return "Select one"
            }
            return PERSON_TYPES_DESC[row - 1]
        }
        return nil
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Row selected: \(row)")
        if pickerView == self.pickerMe {
            self.inputAboutMe.text = self.pickerView(self.pickerMe, titleForRow: row, forComponent: component)
            self.aboutSelf = PERSON_TYPES[row]
        }
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == self.inputWhere && self.inputWhere.text?.isEmpty == true {
            self.simpleAlert("Other cities coming soon", message: "BondVoyage is currently only available in Boston.", completion: { () -> Void in
                self.inputWhere.text = "Boston"
            })
            return false
        }
        else if textField == self.inputWhen && self.inputWhen.text?.isEmpty == true {
            self.simpleAlert("Scheduling coming soon", message: "Search for activities to do right now. Scheduling future activities will be available soon", completion: { () -> Void in
                self.inputWhen.text = "Now"
            })
            return false
        }
        return true
    }
    /*
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        self.validateFields(textField)
        return true
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
        self.currentInput!.resignFirstResponder()
    }
    */
    
    func endEditing() {
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - keyboard notifications
    func keyboardWillShow(n: NSNotification) {
        let size = n.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
//        self.constraintBottomOffset.constant = size!.height
        
        self.view.layoutIfNeeded()
    }
    
    func keyboardWillHide(n: NSNotification) {
//        self.constraintBottomOffset.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func validateFields(input: UITextField) {
        self.view.endEditing(true)
        self.firstName = self.inputFirstName.text
        self.lastName = self.inputLastName.text
        if self.inputBirthYear.text != "Select your birth year" {
            self.birthYear = Int(self.inputBirthYear.text!)
        }
        
        self.updateProfile()
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToInvite" {
            let controller = segue.destinationViewController as! InviteViewController
            controller.category = self.category
            controller.activities = self.selectedActivities
        }
    }

}
