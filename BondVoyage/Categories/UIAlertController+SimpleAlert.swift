//
//  UIAlertController+SimpleAlert.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/5/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func simpleAlert(_ title: String, message: String?, completion: (() -> Void)?) -> UIAlertController {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = UIColor.black
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            print("cancel")
            if completion != nil {
                completion!()
            }
        }))
        return alert
    }

}
