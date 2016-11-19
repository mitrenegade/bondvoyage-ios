//
//  Activity.swift
//  BondVoyage
//
//  Created by Bobby Ren on 11/9/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class Activity: PFObject {
    @NSManaged var category: String?
    @NSManaged var city: String?
    @NSManaged var status: String?
    @NSManaged var fromTime: NSDate?
    @NSManaged var toTime: NSDate?
    @NSManaged var expiration: NSDate?
    
    @NSManaged var owner: PFUser?
}

extension Activity: PFSubclassing {
    static func parseClassName() -> String {
        return "Activity"
    }
}

extension Activity {
    // User creates a new activity that is available for others to join
    class func createActivity(category: CATEGORY, city: String, fromTime: NSDate?, toTime: NSDate?, completion: @escaping ((_ result: Activity?, _ error: NSError?)->Void)) {
        var params: [String: AnyObject] = ["category": category.rawValue.lowercased() as AnyObject, "city": city as AnyObject]
        if let from = fromTime {
            params["fromTime"] = from
        }
        if let to = toTime {
            params["toTime"] = to
        }
        
        PFCloud.callFunction(inBackground: "v3createActivity", withParameters: params) { (results, error) -> Void in
            if let dict = results as? [String: AnyObject] {
                print("results: \(results)")
                if let activity: Activity = dict["activity"] as? Activity,  let success = dict["success"] as? Bool, let message = dict["message"] as? String {
                    print("createActivity resulted in activity \(activity.objectId!), message: \(message)")
                    PFUser.current()!.setObject(activity, forKey: "activity")
                    completion(activity, nil)
                }
                else {
                    completion(nil, nil)
                }
            }
            else {
                print("error \(error)")
                completion(nil, error as NSError?)
            }
        }
    }
    
    class func queryActivities(user: PFUser?, category: String?, completion: @escaping ((_ results: [Activity]?, _ error: NSError?)->Void)) {
        
        var params: [String: AnyObject] = [String: AnyObject]()
        if category != nil {
            params["category"] = category as AnyObject?
        }
        if let user = user, let objectId = user.objectId {
            params["userId"] = objectId as AnyObject?
        }
        PFCloud.callFunction(inBackground: "v3queryActivities", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results as? [Activity], error as NSError?)
        }
    }
    
    class func cancelCurrentActivity(completion: ((_ success: Bool, _ error: NSError?)->Void)?) {
        
        PFCloud.callFunction(inBackground: "v3cancelActivity", withParameters: nil) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            let success = error == nil
            completion?(success, error as NSError?)
        }
    }
    
    class func inviteToJoinActivity(activityId: String, inviteeId: String) {
        // activityId: own activity to add invitee
        // inviteeId: user to invite to chat/join chat
        let params: [String: String] = ["activityId": activityId, "inviteeId": inviteeId]
        PFCloud.callFunction(inBackground: "v3inviteToJoinActivity", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
        }
    }
}
