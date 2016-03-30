//
//  UIViewController+Utils.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/30/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit
import Parse
import AsyncImageView

extension UIViewController {
    
    func simpleAlert(title: String, defaultMessage: String?, error: NSError?) {
        if error != nil {
            if let msg = error!.userInfo["error"] as? String {
                self.simpleAlert(title, message: msg)
                return
            }
        }
        self.simpleAlert(title, message: defaultMessage)
    }
    
    func simpleAlert(title: String, message: String?) {
        self.simpleAlert(title, message: message, completion: nil)
    }
    
    func simpleAlert(title: String, message: String?, completion: (() -> Void)?) {
        let alert: UIAlertController = UIAlertController.simpleAlert(title, message: message, completion: completion)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func appDelegate() -> AppDelegate {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    func setTitleBarColor(color: UIColor, tintColor: UIColor) {
        self.navigationController?.navigationBar.tintColor = tintColor
        self.navigationController?.navigationBar.backgroundColor = color
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setLeftProfileButton() {
        let user = PFUser.currentUser()
        if user == nil {
            self.navigationItem.leftBarButtonItem = nil
            return
        }
        
        let frame = CGRectMake(0, 0, 32, 32)
        let imageView: AsyncImageView = AsyncImageView(frame: frame)
        imageView.contentMode = .ScaleAspectFill
        user!.fetchInBackgroundWithBlock({ (result, error) -> Void in
            if result != nil {
                if let photoURL: String = result!.valueForKey("photoUrl") as? String {
                    imageView.imageURL = NSURL(string: photoURL)
                }
                else {
                    imageView.image = UIImage(named: "profile-icon")
                }
            }
        })

        let view: UIView = UIView(frame: frame)
        view.backgroundColor = UIColor.clearColor()
        view.clipsToBounds = true
        view.layer.cornerRadius = frame.size.width / 2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.whiteColor().CGColor
        
        let button: UIButton = UIButton(frame: frame)
        button.backgroundColor = UIColor.clearColor()
        button.addTarget(self, action: "didClickProfile:", forControlEvents: .TouchUpInside)
        
        view.addSubview(imageView)
        view.addSubview(button)
        
        let left: UIBarButtonItem = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItem = left
    }
    
    func didClickProfile(sender: UIButton) {
        let nav: UINavigationController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("ProfileNavigationViewController") as! UINavigationController
        let controller: UserDetailsViewController = nav.viewControllers[0] as! UserDetailsViewController
        controller.title = "My Profile"
        controller.selectedUser = PFUser.currentUser()
        self.presentViewController(nav, animated: true) { () -> Void in
            controller.scrollView.layoutSubviews()
        }
    }
    
    func stringFromArray(arr: Array<String>) -> String {
        var interestsString = String()
        for interest in arr {
            if interestsString.characters.count == 0 {
                interestsString = interest
            } else {
                interestsString = interestsString + ", " + interest
            }
        }
        return interestsString
    }
}