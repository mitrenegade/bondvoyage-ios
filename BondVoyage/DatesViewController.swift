//
//  DatesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 11/8/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

protocol DatesViewDelegate: class {
    func didSelectDates(_ startDate: Date?, endDate: Date?)
}

class DatesViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputFrom: UITextField!
    @IBOutlet weak var inputTo: UITextField!
    
    let fromDatePicker = UIDatePicker()
    let toDatePicker = UIDatePicker()
    
    var fromDate: Date?
    var toDate: Date?
    
    weak var currentInput: UITextField?
    @IBOutlet weak var constraintCenterOffset: NSLayoutConstraint!
    
    weak var delegate: DatesViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for picker in [fromDatePicker, toDatePicker] {
            picker.sizeToFit()
            picker.backgroundColor = .white

            picker.datePickerMode = UIDatePickerMode.dateAndTime
            picker.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
            
            let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let keyboardDoneButtonView = UIToolbar()
            keyboardDoneButtonView.sizeToFit()
            keyboardDoneButtonView.barStyle = UIBarStyle.default
            keyboardDoneButtonView.tintColor = UIColor.white
            let save: UIBarButtonItem = UIBarButtonItem(title: picker == fromDatePicker ? "Next" : "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(doneWithDate))
            save.tintColor = Constants.BV_defaultBlueColor()
            keyboardDoneButtonView.setItems([flex, save], animated: true)
            
            if picker == fromDatePicker {
                inputFrom.inputAccessoryView = keyboardDoneButtonView
            }
            else {
                inputTo.inputAccessoryView = keyboardDoneButtonView
            }
        }
        fromDatePicker.minimumDate = Date()
        
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
    
    func datePickerValueChanged(_ sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        let date = sender.date
        let dateString = dateFormatter.string(from: sender.date)
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
    
    @IBAction func findActivityNow() {
        fromDate = Date()
        toDate = nil
        self.done()
    }

    // MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentInput = textField
        
        if textField == inputTo {
            self.constraintCenterOffset.constant = -40
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.inputFrom {
//            self.city = textField.text
        }
        else if textField == self.inputTo {
            self.constraintCenterOffset.constant = 0
            self.view.setNeedsUpdateConstraints()
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
}
