//
//  UIViewController+Utils.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/30/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit

extension UIViewController {
    // for other classes that are not UIViewControllers like AppDelegate
    class func simpleAlert(title: String, message: String?, completion: (() -> Void)?) -> UIAlertController {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.view.tintColor = UIColor.blackColor()
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            print("cancel")
            if completion != nil {
                completion!()
            }
        }))
        return alert
    }
    
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
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.view.tintColor = UIColor.blackColor()
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            print("cancel")
            if completion != nil {
                completion!()
            }
        }))
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
}