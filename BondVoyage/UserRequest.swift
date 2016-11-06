//
//  UserRequest.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/12/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//
// TODO: here are the interests currently in the database. Just FYI, for testing purposes
// 	var interests = ["video games", "taekwondo", "surfing", "beer", "modern art", "dancing", "classical music", "rock music", "hiphop", "basketball", "hiking", "painting", "books", "web design", "hacking", "cooking"]

import UIKit
import Parse

class UserRequest: NSObject {
    class func seed() {
        // private function for testing purposes only
        PFCloud.callFunctionInBackground("seedTestUsers", withParameters: nil) { (results, error) -> Void in
            if error != nil {
                print("seedTestUsers error: \(error)")
            }
            else {
                print("seedTestUSers results: \(results)")
            }
        }
    }
    
    // MARK: - Match Queries
    
    // query for all users on Parse with given interests
    class func userQuery(interests: [String], completion: ((results: [PFUser]?, error: NSError?)->Void)) {
        // TODO: call queryUsers; handle nil or unspecified default search criteria
        PFCloud.callFunctionInBackground("v3queryUsers", withParameters: ["interests": interests]) { (results, error) -> Void in
            print("results: \(results)")
            let users: [PFUser]? = results as? [PFUser]
            completion(results: users, error: error)
        }
    }
    
    class func inviteUser(user: PFUser, interests: [String], completion: ((success: Bool, error: NSError?)->Void)) {
        PFCloud.callFunctionInBackground("inviteUser", withParameters: ["user": user.objectId!, "interests": interests]) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(success: error == nil, error: error)
        }
    }
}
