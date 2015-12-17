//
//  UserRequest.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/12/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit

var _userTable: [BVUser]?

class UserRequest: NSObject {
    private class func seed() {
        _userTable = [BVUser]()
        self.createUsers()
    }
    
    private class func createUsers() {
        let usersDict = [
            ["id": 1, "name": "Amy", "interests": self.randomInterests()],
            ["id": 1, "name": "Bobby", "interests":  self.randomInterests() ],
            ["id": 1, "name": "Chris", "interests":  self.randomInterests() ],
            ["id": 1, "name": "Danielle", "interests":  self.randomInterests()],
            ["id": 1, "name": "Erica", "interests":  self.randomInterests() ],
            ["id": 1, "name": "Fredson", "interests": self.randomInterests() ],
            ["id": 1, "name": "Ginger", "interests":  self.randomInterests() ],
            ["id": 1, "name": "Irene", "interests":  self.randomInterests() ],
            ["id": 1, "name": "Jake", "interests": self.randomInterests() ],
            ["id": 1, "name": "Kyle", "interests": self.randomInterests() ]
        ]
        
        // TODO: create users on parse
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
