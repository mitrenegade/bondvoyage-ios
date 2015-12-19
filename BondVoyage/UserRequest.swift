//
//  UserRequest.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/12/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit
import Parse

class UserRequest: NSObject {
    class func seed() {
        PFCloud.callFunctionInBackground("seedTestUsers", withParameters: nil) { (results, error) -> Void in
            if error != nil {
                print("seedTestUsers error: \(error)")
            }
            else {
                print("seedTestUSers results: \(results)")
            }
        }
    }
    
    class func usersMatchingInterests(interests: [String], completion: ((results: [PFUser]?, error: NSError?)->Void)) {
        // query for all users on Parse with given interests
        
        PFCloud.callFunctionInBackground("queryUsersWithInterests", withParameters: ["interests": interests]) { (results, error) -> Void in
            print("results: \(results)")
            let users: [PFUser]? = results as? [PFUser]
            completion(results: users, error: error)
        }
    }
}
