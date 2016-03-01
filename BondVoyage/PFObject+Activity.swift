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
    
    // TODO: not used
    func fetchPlace(completion: ((BVPlace?) -> Void)) -> ()
    {
        if let placeId: String = self.objectForKey("placeId") as? String {
            GoogleDataProvider.fetchDetailsFromPlaceId(placeId, completion: { (dictionary) -> Void in
                if dictionary != nil {
//                    self.place = BVPlace(dictionary: dictionary!, allowedTypes: nil)
                }
                completion(nil)
            })
        }
        else {
            completion(nil)
        }
    }
    
    func subcategory() -> SUBCATEGORY {
        // converts a string format of the category to the enum
        // if multiple exists, returns the first one
        if let categories: [String] = self.objectForKey("categories") as? [String] {
            let subcategory: String = categories[0].capitalizeFirst
            if let sub = CategoryFactory.subcategoryForString(subcategory) {
                return sub
            }
        }
        return .Other
    }
    
    func locationString() -> String? {
        if let locationString: String? = self.objectForKey("locationString") as? String {
            return locationString
        }
        return nil
    }

    func defaultImage() -> UIImage {
        return CategoryFactory.subcategoryBgImage(self.subcategory().rawValue)
    }
    
    func user() -> PFUser {
        // warning: may need to fetchInBackground
        return self.objectForKey("user") as! PFUser
    }
    
    func shortTitle() -> String {
        // warning: may need to fetchInBackground
        var name: String? = self.user().valueForKey("firstName") as? String
        if name == nil {
            name = self.user().valueForKey("lastName") as? String
        }
        if name == nil {
            name = self.user().username
        }
        
        var title = CategoryFactory.subcategoryReadableString(self.subcategory())
        if name != nil && self.locationString() != nil {
            title = "\(title) with \(name!) in \(self.locationString()!)"
        }
        else if name != nil {
            title = "\(title) with \(name!)"
        }
        else if self.locationString() != nil {
            title = "\(title) in \(self.locationString()!)"
        }
        
        return title
    }
    
    func lat() -> Double? {
        if let geopoint = self.objectForKey("geopoint") as? PFGeoPoint {
            return geopoint.latitude
        }
        return nil
    }
    
    func lon() -> Double? {
        if let geopoint = self.objectForKey("geopoint") as? PFGeoPoint {
            return geopoint.longitude
        }
        return nil
    }
    
    func isOwnActivity() -> Bool {
        if PFUser.currentUser() == nil {
            return false
        }
        if PFUser.currentUser()!.objectId == self.user().objectId {
            return true
        }
        return false
    }
    
    func isJoiningActivity() -> Bool {
        if PFUser.currentUser() == nil {
            return false
        }
        if let joining = self.objectForKey("joining") as? [String] {
            if joining.contains(PFUser.currentUser()!.objectId!) {
                return true
            }
        }
        
        return false
    }
    
    func isAcceptedActivity() -> Bool {
        if let status = self.objectForKey("status") as? String {
            return status == "matched"
        }
        return false
    }
    
    func suggestedPlaces() -> [[String: String]] {
        if let places: [[String: String]] = self.objectForKey("places") as? [[String: String]] {
            return places
        }
        return []
    }
}