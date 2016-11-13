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
    class func createActivity(category: CATEGORY, city: String, fromTime: NSDate?, toTime: NSDate?, completion: ((result: Activity?, error: NSError?)->Void)) {
        var params: [String: AnyObject] = ["category": category.rawValue.lowercaseString, "city": city]
        if let from = fromTime {
            params["fromTime"] = from
        }
        if let to = toTime {
            params["toTime"] = to
        }
        
        PFCloud.callFunctionInBackground("v3createActivity", withParameters: params) { (results, error) -> Void in
            if let results = results as? [NSObject: AnyObject] {
                print("results: \(results)")
                if let activity: Activity = results["activity"] as? Activity,  let success = results["success"] as? Bool, let message = results["message"] as? String {
                    print("createActivity resulted in activity \(activity.objectId!), message: \(message)")
                    PFUser.currentUser()!.setObject(activity, forKey: "activity")
                    completion(result: activity, error: nil)
                }
                else {
                    completion(result: nil, error: nil)
                }
            }
            else {
                print("error \(error)")
                completion(result: nil, error: error)
            }
        }
    }
    
    class func queryActivities(user: PFUser?, category: String?, completion: ((results: [Activity]?, error: NSError?)->Void)) {
        
        var params: [String: AnyObject] = [String: AnyObject]()
        if category != nil {
            params["category"] = category
        }
        if let user = user, let objectId = user.objectId {
            params["userId"] = objectId
        }
        PFCloud.callFunctionInBackground("v3queryActivities", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results: results as? [Activity], error: error)
        }
    }
    
}
