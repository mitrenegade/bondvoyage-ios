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
        NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
    }
}
