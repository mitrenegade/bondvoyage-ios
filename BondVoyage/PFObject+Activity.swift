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
    
    func category() -> String {
        if let categories: [String] = self.objectForKey("categories") as? [String] {
            return categories[0].capitalizeFirst
        }
        return ""
    }
    
    func city() -> String? {
        if let city: String? = self.objectForKey("city") as? String {
            return city
        }
        return nil
    }

    func defaultImage() -> UIImage {
        return CategoryFactory.subcategoryBgImage(self.category())
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
        
        var title = "\(self.category())"
        if name != nil && self.city() != nil {
            title = "\(self.category()) with \(name!) in \(self.city()!)"
        }
        else if name != nil {
            title = "\(title) with \(name!)"
        }
        else if self.city() != nil {
            title = "\(title) in \(self.city()!)"
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
}