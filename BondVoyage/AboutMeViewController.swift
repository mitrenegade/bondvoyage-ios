//
//  AboutMeViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/1/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class AboutMeViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var inputInterests: UITextView!
    @IBOutlet weak var constraintBottomOffset: NSLayoutConstraint!
    @IBOutlet weak var placeholder: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.inputInterests.layer.cornerRadius = 5
        self.inputInterests.layer.borderWidth = 2
        self.inputInterests.layer.borderColor = Constants.blueColor().cgColor

        NotificationCenter.default.addObserver(self, selector: #selector(AboutMeViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AboutMeViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        let keyboardDoneButtonView: UIToolbar = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        keyboardDoneButtonView.barStyle = UIBarStyle.black
        keyboardDoneButtonView.tintColor = UIColor.white
        let button: UIBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.done, target: self, action: #selector(AboutMeViewController.dismissKeyboard))
        let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.setItems([flex, button], animated: true)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(AboutMeViewController.updateProfile))

        if PFUser.current() != nil {
            let user: PFUser = PFUser.current()!
            user.fetchInBackground(block: { (result, error) -> Void in
                if result != nil {
                    if let about = result!.object(forKey: "about") as? String {
                        self.inputInterests.text = about
                        self.placeholder.isHidden = true
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
    func keyboardWillShow(_ n: Notification) {
        let size = (n.userInfo![UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue.size
        self.constraintBottomOffset.constant = size.height + 20
        
        self.view.layoutIfNeeded()
    }
    
    func keyboardWillHide(_ n: Notification) {
        self.constraintBottomOffset.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func updateProfile() {
        let user = PFUser.current()
        if user == nil {
            self.simpleAlert("Could not update profile", message: "Please log in or sign up")
            return
        }
        if let about: String = inputInterests.text! {
            user!.setObject(about, forKey: "about")
            user!.saveInBackground(block: { (success, error) -> Void in
                if success {
                    print("done")
                    self.view.endEditing(true)
                    self.simpleAlert("Profile updated", message: nil, completion: { () -> Void in
                        self.navigationController!.popViewController(animated: true)
                    })
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.placeholder.isHidden = true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if self.inputInterests.text == nil || self.inputInterests.text!.characters.count == 0 {
            self.placeholder.isHidden = false
        }
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        self.inputInterests.resignFirstResponder()
        return true
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
