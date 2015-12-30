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

class SignUpViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var pickerGender: UIPickerView = UIPickerView()
    var pickerBirthdate: UIPickerView = UIPickerView()
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
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Year], fromDate: date)
        currentYear = components.year
        
        // pickers for age and gender
        pickerGender.delegate = self
        pickerGender.dataSource = self
        pickerBirthdate.delegate = self
        pickerBirthdate.dataSource = self

        keyboardDoneButtonView.sizeToFit()
        keyboardDoneButtonView.barStyle = UIBarStyle.Black
        keyboardDoneButtonView.tintColor = UIColor.whiteColor()
        let button: UIBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Done, target: self, action: "dismissKeyboard")
        let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.setItems([flex, button], animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // sign up, profile info
        return 2;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        return 4
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view: UIView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 60))
        view.backgroundColor = UIColor.blueColor()
        let label: UILabel = UILabel(frame: CGRectMake(8, 0, self.tableView.frame.size.width - 16, 60))
        label.textAlignment = .Left
        label.font = UIFont(name: "Lato-Medium", size: 20)
        label.textColor = UIColor.whiteColor()
        view.addSubview(label)
        if section == 0 {
            label.text = "New User"
        }
        else if section == 1 {
            label.text = "Current User: "
        }
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row: Int = indexPath.row
        let section: Int = indexPath.section
        
        let cell: UITableViewCell
        
        if section == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier(kInputCellIdentifier, forIndexPath: indexPath)
            let label: UILabel = cell.viewWithTag(1) as! UILabel
            let input: UITextField = cell.viewWithTag(2) as! UITextField
            input.inputView = nil
            input.inputAccessoryView = self.keyboardDoneButtonView
            
            if row == 0 {
                input.keyboardType = .EmailAddress
                label.text = "Email"
                input.placeholder = "Enter your email"
            }
            else if row == 1 {
                input.secureTextEntry = true
                label.text = "Password"
                input.placeholder = "Enter a new password"
            }
            else if row == 2 {
                input.secureTextEntry = true
                label.text = "Confirmation"
                input.placeholder = "Enter password again"
            }
        }
        else {
            cell = tableView.dequeueReusableCellWithIdentifier(kInputCellIdentifier, forIndexPath: indexPath)
            let label: UILabel = cell.viewWithTag(1) as! UILabel
            let input: UITextField = cell.viewWithTag(2) as! UITextField
            input.inputView = nil
            input.inputAccessoryView = self.keyboardDoneButtonView
            
            if row == 0 {
                label.text = "First Name"
                input.placeholder = "Enter your first name"
            }
            else if row == 1 {
                label.text = "Last Name"
                input.placeholder = "Enter your last name"
            }
            else if row == 2 {
                label.text = "Gender"
                input.inputView = self.pickerGender
                input.placeholder = "Select your gender"
            }
            else if row == 3 {
                label.text = "Age"
                input.inputView = self.pickerBirthdate
                input.placeholder = "Select your birth year"
            }
        }
        return cell
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
            self.gender = genders[row]
        }
        else {
            self.birthYear = currentYear - row
        }
    }

}
