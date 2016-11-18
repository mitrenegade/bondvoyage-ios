//
//  PFObject+Activity.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/24/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import Foundation
import Parse

extension PFObject {
        
    func category() -> CATEGORY? {
        // converts a string format of the category to the enum
        // if multiple exists, returns the first one
        if let categories: [String] = self.object(forKey: "categories") as? [String] {
            let category: String = categories[0].capitalizeFirst
            if let cat = CategoryFactory.categoryForString(category) {
                return cat
            }
        }
        return nil
    }

    func locationString() -> String? {
        if let locationString: String? = self.object(forKey: "locationString") as? String {
            return locationString
        }
        return nil
    }

    func defaultImage() -> UIImage {
        guard let category = self.category() else { return UIImage() }
        return CategoryFactory.categoryBgImage(category.rawValue)
    }
    
    func user() -> PFUser {
        // warning: may need to fetchInBackground
        return self.object(forKey: "user") as! PFUser
    }
    
    func getJoiningUser(_ completion: @escaping ( (PFUser?)->Void )) {
        // returns first PFUser on the joining list
        if let userIds: [String] = self.object(forKey: "joining") as? [String] {
            let userId = userIds[0]
            let query: PFQuery = PFUser.query()!
            query.whereKey("objectId", equalTo: userId)
            query.findObjectsInBackground { (results, error) -> Void in
                if results != nil && results!.count > 0 {
                    let user: PFUser = results![0] as! PFUser
                    completion(user)
                }
                else {
                    completion(nil)
                }
            }
        }
        else {
            completion(nil)
        }
    }
    
    func getMatchedUser(_ completion: @escaping ( (PFUser?)->Void )) {
        // returns the other user whether it's the owner of the activity or the first joiner
        if self.isOwnActivity() {
            self.getJoiningUser(completion)
        }
        else {
            self.user().fetchInBackground(block: { (object, error) in
                let user = object as? PFUser
                completion(user)
            })
        }
    }
    
    func shortTitle() -> String {
        // warning: may need to fetchInBackground
        var name: String? = self.user().value(forKey: "firstName") as? String
        if name == nil {
            name = self.user().value(forKey: "lastName") as? String
        }
        if name == nil {
            name = self.user().username
        }
        
        var title = ""
        if let category = self.category() {
            title = "\(CategoryFactory.categoryReadableString(category))"
        }
        
        if name != nil {
            title = "\(title) with \(name!)"
        }
        else if self.locationString() != nil {
            title = "\(title) in \(self.locationString()!)"
        }
        
        return title
    }
    
    func lat() -> Double? {
        if let geopoint = self.object(forKey: "geopoint") as? PFGeoPoint {
            return geopoint.latitude
        }
        return nil
    }
    
    func lon() -> Double? {
        if let geopoint = self.object(forKey: "geopoint") as? PFGeoPoint {
            return geopoint.longitude
        }
        return nil
    }
    
    func isOwnActivity() -> Bool {
        if PFUser.current() == nil {
            return false
        }
        if PFUser.current()!.objectId == self.user().objectId {
            return true
        }
        return false
    }
    
    func isJoiningActivity() -> Bool {
        if PFUser.current() == nil {
            return false
        }
        if let joining = self.object(forKey: "joining") as? [String] {
            if joining.contains(PFUser.current()!.objectId!) {
                return true
            }
        }
        
        return false
    }
    
    func isAcceptedActivity() -> Bool {
        if let status = self.object(forKey: "status") as? String {
            return status == "matched"
        }
        return false
    }
    
    func suggestedPlaces() -> [String: String] {
        if let places: [String: String] = self.object(forKey: "places") as? [String: String] {
            return places
        }
        return [:]
    }
}
