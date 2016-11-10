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
    @NSManaged var status: String?
    @NSManaged var fromTime: NSDate?
    @NSManaged var toTime: NSDate?
    @NSManaged var expiration: NSDate?
    @NSManaged var city: String?
}

extension Activity: PFSubclassing {
    static func parseClassName() -> String {
        return "Activity"
    }
}

// MARK: ActivityService
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
            print("results: \(results)")
            let activity: Activity? = results as? Activity
            completion(result: activity, error: error)
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
            let activities: [Activity]? = results as? [Activity]
            completion(results: activities, error: error)
        }
    }
    
}
