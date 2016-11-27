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
    func simpleAlert(_ title: String, defaultMessage: String?, error: NSError?) {
        self.simpleAlert(title, defaultMessage: defaultMessage, error: error, completion: nil)
    }
    
    func simpleAlert(_ title: String, defaultMessage: String?, error: NSError?, completion: (() -> Void)?) {
        if error != nil {
            if let msg = error!.userInfo["error"] as? String {
                self.simpleAlert(title, message: msg)
                return
            }
        }
        self.simpleAlert(title, message: defaultMessage, completion: completion)
    }
    
    func simpleAlert(_ title: String, message: String?) {
        self.simpleAlert(title, message: message, completion: nil)
    }
    
    func simpleAlert(_ title: String, message: String?, completion: (() -> Void)?) {
        let alert: UIAlertController = UIAlertController.simpleAlert(title, message: message, completion: completion)
        self.present(alert, animated: true, completion: nil)
    }
    
    func appDelegate() -> AppDelegate {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate
    }
    
    func isValidEmail(_ testStr:String) -> Bool {
        // http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func setTitleBarColor(_ color: UIColor, tintColor: UIColor) {
        self.navigationController?.navigationBar.tintColor = tintColor
        self.navigationController?.navigationBar.backgroundColor = color
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setLeftProfileButton() {
        let user = PFUser.current()
        if user == nil {
            self.navigationItem.leftBarButtonItem = nil
            return
        }
        
        let frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        let imageView: AsyncImageView = AsyncImageView(frame: frame)
        imageView.contentMode = .scaleAspectFill
        user!.fetchInBackground(block: { (result, error) -> Void in
            if result != nil {
                if let photoURL: String = result!.value(forKey: "photoUrl") as? String {
//                    imageView.imageURL = NSURL(string: photoURL)
                    imageView.setValue(URL(string: photoURL), forKey: "imageURL")
                }
                else {
                    imageView.image = UIImage(named: "profile")
                }
            }
        })

        let view: UIView = UIView(frame: frame)
        view.backgroundColor = UIColor.clear
        view.clipsToBounds = true
        view.layer.cornerRadius = frame.size.width / 2
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        
        let button: UIButton = UIButton(frame: frame)
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(UIViewController.didClickProfile(_:)), for: .touchUpInside)
        
        view.addSubview(imageView)
        view.addSubview(button)
        
        let left: UIBarButtonItem = UIBarButtonItem(customView: view)
        self.navigationItem.leftBarButtonItem = left
    }
    
    func didClickProfile(_ sender: UIButton) {
        let nav: UINavigationController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "ProfileNavigationViewController") as! UINavigationController
        let controller: UserDetailsViewController = nav.viewControllers[0] as! UserDetailsViewController
        controller.title = "My Profile"
        controller.selectedUser = PFUser.current()
        self.present(nav, animated: true) { () -> Void in
            controller.scrollView.layoutSubviews()
        }
    }
    
    func stringFromArray(_ arr: Array<String>) -> String {
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
