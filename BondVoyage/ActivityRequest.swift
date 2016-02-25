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
    class func createActivity(categories: [String], location: CLLocation, completion: ((result: PFObject?, error: NSError?)->Void)) {
        PFCloud.callFunctionInBackground("createActivity", withParameters: ["categories": categories, "lat": location.coordinate.latitude, "lon": location.coordinate.longitude]) { (results, error) -> Void in
            print("results: \(results)")
            let activity: PFObject? = results as? PFObject
            completion(result: activity, error: error)
        }
    }
    
    class func queryActivities(location: CLLocation?, user: PFUser?, categories: [String]?, completion: ((results: [PFObject]?, error: NSError?)->Void)) {
        
        var params: [String: AnyObject] = [String: AnyObject]()
        if categories != nil {
            params["categories"] = categories
        }
        if location != nil {
            params["lat"] = location!.coordinate.latitude
            params["lon"] = location!.coordinate.longitude
        }
        if user != nil {
            params["userId"] = user!.objectId!
        }
        
        PFCloud.callFunctionInBackground("queryActivities", withParameters: params) { (results, error) -> Void in
            print("results: \(results)")
            let activities: [PFObject]? = results as? [PFObject]
            completion(results: activities, error: error)
        }
    }
    
    class func joinActivity(activity: PFObject, suggestedPlace: BVPlace, completion: ((results: AnyObject?, error: NSError?) -> Void)) {
        PFCloud.callFunctionInBackground("joinActivity", withParameters: ["activity": activity.objectId!, "place": suggestedPlace.placeId!]) { (results, error) -> Void in
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
    class func respondToJoin(activity: PFObject, responseType: String?, completion: ((results: AnyObject?, error: NSError?)->Void)) {
        var params =  ["activity": activity.objectId!]
        if responseType != nil {
            params["responseType"] = responseType
        }
        PFCloud.callFunctionInBackground("respondToJoin", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results: results, error: error)
        }
    }
}
