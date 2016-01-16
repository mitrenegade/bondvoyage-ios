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
        PFCloud.callFunctionInBackground("queryUsers", withParameters: ["interests": interests]) { (results, error) -> Void in
            print("results: \(results)")
            let users: [PFUser]? = results as? [PFUser]
            completion(results: users, error: error)
        }
    }

    // query for all users with interests, age range default
    class func userQuery(interests: [String], genderPref: [String], ageRange: [Int], numRange: [Int], completion: ((results: [PFUser]?, error: NSError?)->Void)) {
        // query for all users on Parse with given interests plus default search criteria

        // converts to lowercase
        let interestsString: [String] = interests.map { (i) -> String in
            return i.lowercaseString
        }

        // converts to lowercase
        let genderString: [String] = genderPref.map { (g) -> String in
            return g.lowercaseString
        }
        
        PFCloud.callFunctionInBackground("queryUsers", withParameters: ["interests": interests, "gender": genderString, "age": ageRange, "number": numRange]) { (results, error) -> Void in
            print("results: \(results)")
            let users: [PFUser]? = results as? [PFUser]
            completion(results: users, error: error)
        }
    }
    
    class func inviteUser(user: PFUser, interests: [String], completion: ((success: Bool, error: NSError?)->Void)) {
        PFCloud.callFunctionInBackground("inviteUser", withParameters: ["user": user.objectId!, "interests": interests]) { (results, error) -> Void in
            print("results: \(results)")
            completion(success: error == nil, error: error)
        }
    }
}
