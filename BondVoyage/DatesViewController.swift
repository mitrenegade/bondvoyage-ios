//
//  DatesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 11/8/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

protocol DatesViewDelegate: class {
    func didSelectDates(startDate: NSDate?, endDate: NSDate?)
}

class DatesViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputFrom: UITextField!
    @IBOutlet weak var inputTo: UITextField!
    
    let fromDatePicker = UIDatePicker()
    let toDatePicker = UIDatePicker()
    
    var fromDate: NSDate?
    var toDate: NSDate?
    
    weak var currentInput: UITextField?
    
    weak var delegate: DatesViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for picker in [fromDatePicker, toDatePicker] {
            picker.sizeToFit()
            picker.backgroundColor = .whiteColor()

            picker.datePickerMode = UIDatePickerMode.DateAndTime
            picker.addTarget(self, action: #selector(datePickerValueChanged), forControlEvents: UIControlEvents.ValueChanged)
            
            let keyboardDoneButtonView = UIToolbar()
            keyboardDoneButtonView.sizeToFit()
            keyboardDoneButtonView.barStyle = UIBarStyle.Default
            keyboardDoneButtonView.tintColor = UIColor.whiteColor()
            let save: UIBarButtonItem = UIBarButtonItem(title: picker == fromDatePicker ? "Next" : "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(doneWithDate))
            save.tintColor = self.view.tintColor
            keyboardDoneButtonView.setItems([save], animated: true)
        }
        fromDatePicker.minimumDate = NSDate()
        
        inputFrom.inputAccessoryView = fromDatePicker
        inputTo.inputAccessoryView = toDatePicker
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func done() {
        // save dates
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let date = sender.date
        let dateString = dateFormatter.stringFromDate(sender.date)
        if sender == fromDatePicker {
            inputFrom.text = dateString
            fromDate = date
        }
        else {
            inputTo.text = dateString
            toDate = date
        }
    }
    
    func doneWithDate() {
        if currentInput == inputFrom {
            inputFrom.resignFirstResponder()
            toDatePicker.minimumDate = fromDatePicker.date
            inputTo.becomeFirstResponder()
        }
        else {
            self.done()
        }
    }

    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(textField: UITextField) {
        currentInput = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == self.inputFrom {
//            self.city = textField.text
        }
        else if textField == self.inputTo {
//            self.location = textField.text
        }
    }
    
}
