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
    
    private class func randomInterests() -> [String]{
        let interests = ["video games", "taekwondo", "surfing", "beer", "modern art", "dancing", "classical music", "rock music", "hiphop", "basketball", "hiking", "painting", "books", "web design", "hacking", "cooking"]
        let total: Int = Int(arc4random_uniform(UInt32(interests.count))) + 1
        var generated: [String] = [String]()
        while generated.count < total {
            let index: Int = Int(arc4random_uniform(UInt32(interests.count)))
            let interest: String = interests[index]
            if !generated.contains(interest) {
                generated.append(interest)
            }
        }
        return generated
    }
    
    func usersMatchingInterests(interests: [String]?, completion: ((results: [BVUser]?, error: NSError)->Void)) {
        // TODO: query for all users on Parse with given interests
    }
}
