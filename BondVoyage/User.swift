//
//  User.swift
//  BondVoyage
//
//  Created by Bobby Ren on 11/26/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class User: PFUser {
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var gender: String?
    @NSManaged var city: String?
    @NSManaged var education: String?
    @NSManaged var occupation: String?
    @NSManaged var about: String?
    @NSManaged var languages: String?
    @NSManaged var birthYear: NSDate?
    @NSManaged var photoUrl: String?
    @NSManaged var group: String?
    @NSManaged var countries: String?
    @NSManaged var interests: [String]
    
    @NSManaged var activity : Activity?
    
    override init () {
        super.init()
    }
    
}

// MARK: Extension for user convenience methods
extension User {
    var displayString: String {
        get {
            if let first = self.firstName, let last = self.lastName {
                return "\(first) \(last)"
            }
            return self.firstName ?? self.lastName ?? self.email ?? "unnamed"
        }
    }
}

var userCache: [String: User] = [String: User]()
extension User {
    class func withId(objectId: String, completion: @escaping ((User?)->Void)) {
        if let result = userCache[objectId] {
            completion(result)
            return
        }
        
        let query = User.query()
        query?.getObjectInBackground(withId: objectId, block: { (result, error) in
            if let user = result as? User {
                userCache[objectId] = user
                completion(user)
            }
            completion(nil)
        })
    }
}

