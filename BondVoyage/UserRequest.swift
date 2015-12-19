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
        self.createUsers()
    }
    
    private class func createUsers() {
        PFCloud.callFunctionInBackground("seedTestUsers", withParameters: nil) { (results, error) -> Void in
            if error != nil {
                print("seedTestUsers error: \(error)")
            }
            else {
                print("seedTestUSers results: \(results)")
            }
        }
    }
    
    class func usersMatchingInterests(interests: [String], completion: ((results: [BVUser]?, error: NSError?)->Void)) {
        // TODO: query for all users on Parse with given interests
        
        PFCloud.callFunctionInBackground("queryUsersWithInterests", withParameters: ["interests": interests]) { (results, error) -> Void in
            print("results: \(results)")
            completion(results: [BVUser](), error: error)
        }
    }
}
