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
            
            let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            let keyboardDoneButtonView = UIToolbar()
            keyboardDoneButtonView.sizeToFit()
            keyboardDoneButtonView.barStyle = UIBarStyle.Default
            keyboardDoneButtonView.tintColor = UIColor.whiteColor()
            let save: UIBarButtonItem = UIBarButtonItem(title: picker == fromDatePicker ? "Next" : "Done", style: UIBarButtonItemStyle.Done, target: self, action: #selector(doneWithDate))
            save.tintColor = Constants.BV_defaultBlueColor()
            keyboardDoneButtonView.setItems([flex, save], animated: true)
            
            if picker == fromDatePicker {
                inputFrom.inputAccessoryView = keyboardDoneButtonView
            }
            else {
                inputTo.inputAccessoryView = keyboardDoneButtonView
            }
        }
        fromDatePicker.minimumDate = NSDate()
        
        inputFrom.inputView = fromDatePicker
        inputTo.inputView = toDatePicker
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func done() {
        // save dates
        self.delegate?.didSelectDates(fromDate, endDate: toDate)
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
            self.datePickerValueChanged(fromDatePicker)
            toDatePicker.minimumDate = fromDatePicker.date
            inputTo.becomeFirstResponder()
        }
        else {
            self.datePickerValueChanged(toDatePicker)
            inputTo.resignFirstResponder()
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
