//
//  InterestsViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/1/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class InterestsViewController: UIViewController {

    @IBOutlet weak var inputInterests: UITextView!
    @IBOutlet weak var constraintBottomOffset: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.inputInterests.layer.cornerRadius = 5
        self.inputInterests.layer.borderWidth = 2
        self.inputInterests.layer.borderColor = Constants.blueColor().CGColor

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        let keyboardDoneButtonView: UIToolbar = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        keyboardDoneButtonView.barStyle = UIBarStyle.Black
        keyboardDoneButtonView.tintColor = UIColor.whiteColor()
        let button: UIBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: "dismissKeyboard")
        let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.setItems([flex, button], animated: true)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .Done, target: self, action: "updateProfile")

        if PFUser.currentUser() != nil {
            let user: PFUser = PFUser.currentUser()!
            user.fetchInBackgroundWithBlock({ (result, error) -> Void in
                if result != nil {
                    if let keywords = result!.objectForKey("interests") as? [String] {
                        var interestString = ""
                        for keyword: String in keywords {
                            interestString = "\(interestString)\(keyword) "
                        }
                        self.inputInterests.text = interestString
                    }
                }
         
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }

    // MARK: - keyboard notifications
    func keyboardWillShow(n: NSNotification) {
        let size = n.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size
        self.constraintBottomOffset.constant = size!.height + 20
        
        self.view.layoutIfNeeded()
    }
    
    func keyboardWillHide(n: NSNotification) {
        self.constraintBottomOffset.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func updateProfile() {
        let user = PFUser.currentUser()
        if user == nil {
            self.simpleAlert("Could not update profile", message: "Please log in or sign up")
            return
        }
        
        if let searchText: String = inputInterests.text! {
            var keywords = searchText.lowercaseString.componentsSeparatedByString(" ")
            if let index: Int = keywords.indexOf("") {
                keywords.removeAtIndex(index)
            }
            user!.setObject(keywords, forKey: "interests")
            user!.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    print("done")
                    self.simpleAlert("Profile updated", message: nil, completion: nil)
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
