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
    
    @NSManaged var invitee: [Any]?
    
    @NSManaged var owner: PFUser?
}

extension Activity: PFSubclassing {
    static func parseClassName() -> String {
        return "Activity"
    }
}

extension Activity {
    // owner is a pointer and if ParseLiveQuery is used, it does not get included as a PFObject
    func fetchOwnerInBackground(completion: ((_ isNew: Bool)->Void)?) throws {
        if let type = self.owner?["__type"] as? String, type == "Pointer" {
            if let objectId = self.owner?["objectId"] as? String {
                print("owner objectId: \(objectId)")
                
                User.withId(objectId: objectId, completion: { (user, isNew) in
                    self.owner = user
                    completion?(isNew)
                })
            }
        }
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
        
        PFCloud.callFunction(inBackground: "v4createOrUpdateActivity", withParameters: params) { (results, error) -> Void in
            if let dict = results as? [String: AnyObject] {
                print("results: \(results)")
                if let activity: Activity = dict["activity"] as? Activity,  let success = dict["success"] as? Bool, let message = dict["message"] as? String {
                    print("createActivity resulted in activity \(activity.objectId!), message: \(message)")
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
    
    class func queryActivities(user: PFUser?, category: CATEGORY?, city: String?, completion: @escaping ((_ results: [Activity]?, _ error: NSError?)->Void)) {
        
        var params: [String: Any] = [String: Any]()
        if let cat = category {
            params["category"] = cat.rawValue.lowercased()
        }
        if let user = user, let objectId = user.objectId {
            params["userId"] = objectId
        }
        if let city = city {
            params["city"] = city
        }
        PFCloud.callFunction(inBackground: "v3queryActivities", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results as? [Activity], error as NSError?)
        }
    }
    
    class func cancelActivityForCategory(category: CATEGORY, completion: ((_ success: Bool, _ error: NSError?)->Void)?) {
        
        PFCloud.callFunction(inBackground: "v4cancelActivity", withParameters: ["category": category.rawValue.lowercased()]) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            let success = error == nil
            completion?(success, error as NSError?)
        }
    }
}
