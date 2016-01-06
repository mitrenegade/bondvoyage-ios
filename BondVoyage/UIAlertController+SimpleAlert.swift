//
//  UIAlertController+SimpleAlert.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/5/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

extension UIAlertController {
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

}