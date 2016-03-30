//
//  ActivityRequest.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/23/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//
// Activity is the refactored Match.

import UIKit
import Parse

class ActivityRequest: NSObject {

    // User creates a new activity that is available for others to join
    class func createActivity(categories: [String], location: CLLocation, locationString: String?, aboutSelf: String?, aboutOthers: [String], ageMin: Int?, ageMax: Int?, completion: ((result: PFObject?, error: NSError?)->Void)) {
        var params: [String: AnyObject] = ["categories": categories, "lat": location.coordinate.latitude, "lon": location.coordinate.longitude, "time": NSDate(), "aboutOthers": aboutOthers]
        if locationString != nil {
            params["locationString"] = locationString!
        }
        if aboutSelf != nil {
            params["aboutSelf"] = aboutSelf
        }
        if ageMin != nil && ageMax != nil {
            params["ageMin"] = ageMin!
            params["ageMax"] = ageMax!
        }
        
        PFCloud.callFunctionInBackground("createActivity", withParameters: params) { (results, error) -> Void in
            print("results: \(results)")
            let activity: PFObject? = results as? PFObject
            completion(result: activity, error: error)
        }
    }
    
    class func queryActivities(user: PFUser?, joining: Bool?, categories: [String]?, location: CLLocation?, distance: Double?, aboutSelf: String?, aboutOthers: [String], completion: ((results: [PFObject]?, error: NSError?)->Void)) {
        
        var params: [String: AnyObject] = [String: AnyObject]()
        if categories != nil {
            params["categories"] = categories
        }
        if location != nil && distance != nil {
            params["lat"] = location!.coordinate.latitude
            params["lon"] = location!.coordinate.longitude
            params["distanceMax"] = distance!
        }
        if user != nil {
            params["userId"] = user!.objectId!
        }
        if joining != nil {
            params["joining"] = joining!
        }
        if aboutSelf != nil {
            // if this is a new activity, send in aboutSelf
            // if this is a query for matched or requested bonds, don't use aboutSelf
            params["aboutSelf"] = aboutSelf!
        }
        if aboutOthers.count > 0 {
            params["aboutOthers"] = aboutOthers
        }
        
        PFCloud.callFunctionInBackground("queryActivities", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            let activities: [PFObject]? = results as? [PFObject]
            completion(results: activities, error: error)
        }
    }
    
    class func joinActivity(activity: PFObject, suggestedPlace: BVPlace?, completion: ((results: AnyObject?, error: NSError?) -> Void)) {
        var params = ["activity": activity.objectId!]
        if suggestedPlace != nil {
            params["place"] = suggestedPlace!.placeId! as String
        }
        PFCloud.callFunctionInBackground("joinActivity", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results: results, error: error)
        }
    }
    
    class func cancelActivity(activity: PFObject, completion: ((results: AnyObject?, error: NSError?)->Void)) {
        PFCloud.callFunctionInBackground("cancelActivity", withParameters: ["activity": activity.objectId!]) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results: results, error: error)
        }
    }
    
    // TODO: accept another user to join
    class func respondToJoin(activity: PFObject, joiningUserId: String?, responseType: String?, completion: ((results: AnyObject?, error: NSError?)->Void)) {
        var params =  ["activity": activity.objectId!]
        if joiningUserId != nil {
            params["userId"] = joiningUserId!
        }
        if responseType != nil {
            params["responseType"] = responseType
        }
        PFCloud.callFunctionInBackground("respondToJoin", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results: results, error: error)
        }
    }
}
