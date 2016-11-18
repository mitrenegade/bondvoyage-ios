//
//  UserService.swift
//  BondVoyage
//
//  Created by Bobby Ren on 9/4/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import Foundation
import Parse
import Quickblox

class UserService: NSObject {
    class func logout() {
        PFUser.logOut()
        QBUserService.sharedInstance.logoutQBUser()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "logout"), object: nil)
    }
}
