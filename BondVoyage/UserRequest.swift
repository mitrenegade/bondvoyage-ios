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
        PFCloud.callFunction(inBackground: "seedTestUsers", withParameters: nil) { (results, error) -> Void in
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
    class func userQuery(_ interests: [String], completion: @escaping ((_ results: [PFUser]?, _ error: NSError?)->Void)) {
        // TODO: call queryUsers; handle nil or unspecified default search criteria
        PFCloud.callFunction(inBackground: "v3queryUsers", withParameters: ["interests": interests]) { (results, error) -> Void in
            print("results: \(results)")
            let users: [PFUser]? = results as? [PFUser]
            completion(users, error as NSError?)
        }
    }
    
    class func inviteUser(_ user: PFUser, interests: [String], completion: @escaping ((_ success: Bool, _ error: NSError?)->Void)) {
        PFCloud.callFunction(inBackground: "inviteUser", withParameters: ["user": user.objectId!, "interests": interests]) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(error == nil, error as NSError?)
        }
    }
}
