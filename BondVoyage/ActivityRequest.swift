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
    class func createActivity(_ categories: [String], location: CLLocation, locationString: String?, aboutSelf: String?, aboutOthers: [String], ageMin: Int?, ageMax: Int?, completion: @escaping ((_ result: PFObject?, _ error: NSError?)->Void)) {
        var params: [String: AnyObject] = ["categories": categories as AnyObject, "lat": location.coordinate.latitude as AnyObject, "lon": location.coordinate.longitude as AnyObject, "time": Date() as AnyObject, "aboutOthers": aboutOthers as AnyObject]
        if locationString != nil {
            params["locationString"] = locationString! as AnyObject?
        }
        if aboutSelf != nil {
            params["aboutSelf"] = aboutSelf as AnyObject?
        }
        if ageMin != nil && ageMax != nil {
            params["ageMin"] = ageMin! as AnyObject?
            params["ageMax"] = ageMax! as AnyObject?
        }
        
        PFCloud.callFunction(inBackground: "createOrUpdateActivity", withParameters: params) { (results, error) -> Void in
            print("results: \(results)")
            let activity: PFObject? = results as? PFObject
            completion(activity, error as NSError?)
        }
    }
    
    class func queryActivities(_ user: PFUser?, categories: [String]?, completion: @escaping ((_ results: [PFObject]?, _ error: NSError?)->Void)) {
        
        var params: [String: AnyObject] = [String: AnyObject]()
        if categories != nil {
            params["categories"] = categories as AnyObject?
        }
        if user != nil {
            params["userId"] = user!.objectId! as AnyObject?
        }
        PFCloud.callFunction(inBackground: "v2queryActivities", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            let activities: [PFObject]? = results as? [PFObject]
            completion(activities, error as NSError?)
        }
    }
    
    class func joinActivity(_ activity: PFObject, suggestedPlace: AnyObject?, completion: @escaping ((_ results: AnyObject?, _ error: NSError?) -> Void)) {
        let params = ["activity": activity.objectId!]
        PFCloud.callFunction(inBackground: "joinActivity", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results as AnyObject?, error as NSError?)
        }
    }
    
    class func cancelActivity(_ activity: PFObject, completion: @escaping ((_ results: AnyObject?, _ error: NSError?)->Void)) {
        PFCloud.callFunction(inBackground: "cancelActivity", withParameters: ["activity": activity.objectId!]) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results as AnyObject?, error as NSError?)
        }
    }
    
    // TODO: accept another user to join
    class func respondToJoin(_ activity: PFObject, joiningUserId: String?, responseType: String?, completion: @escaping ((_ results: AnyObject?, _ error: NSError?)->Void)) {
        var params =  ["activity": activity.objectId!]
        if joiningUserId != nil {
            params["userId"] = joiningUserId!
        }
        if responseType != nil {
            params["responseType"] = responseType
        }
        PFCloud.callFunction(inBackground: "respondToJoin", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results as AnyObject?, error as NSError?)
        }
    }
    
    class func queryMatchedActivities(_ user: PFUser?, completion: @escaping ((_ results: [PFObject]?, _ error: NSError?)->Void)) {
        
        var params: [String: AnyObject] = [String: AnyObject]()
        if user != nil {
            params["userId"] = user!.objectId! as AnyObject?
        }
        
        PFCloud.callFunction(inBackground: "queryMatchedActivities", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            let activities: [PFObject]? = results as? [PFObject]
            completion(activities, error as NSError?)
        }
    }
    
    // MARK: - convenience calls - uses another ActivityRequest call but does some filtering
    class func getRequestedBonds(_ completion: @escaping ( ([PFObject]?, NSError?) -> Void)) {
        var activities: [PFObject] = [PFObject]()
        ActivityRequest.queryActivities(PFUser.current(), categories: nil) { (results, error) -> Void in
            if error != nil {
                completion(nil, error)
            }
            else {
                if results!.count > 0 {
                    for activity: PFObject in results! {
                        if activity.isAcceptedActivity() {
                            // skip matched activities
                            continue
                        }
                        if let joining: [String] = activity.object(forKey: "joining") as? [String] {
                            if joining.count > 0 {
                                activities.append(activity)
                            }
                        }
                    }
                }
                completion(activities, nil)
            }
        }
    }
}
