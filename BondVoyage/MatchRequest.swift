//
//  MatchRequest.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class MatchRequest: NSObject {
    // todo: add CLLocation or other parameters
    
    /* DEPRECATED
    class func createMatch(categories: [String], location: CLLocation, completion: ((result: PFObject?, error: NSError?)->Void)) {
        PFCloud.callFunctionInBackground("createMatchRequest", withParameters: ["categories": categories, "lat": location.coordinate.latitude, "lon": location.coordinate.longitude]) { (results, error) -> Void in
            print("results: \(results)")
            let match: PFObject? = results as? PFObject
            completion(result: match, error: error)
        }
    }
    */
    
    /* DEPRECATED
    class func queryMatches(location: CLLocation?, categories: [String]?, completion: ((results: [PFObject]?, error: NSError?)->Void)) {
        
        var params: [String: AnyObject] = [String: AnyObject]()
        if categories != nil {
            params["categories"] = categories
        }
        if location != nil {
            params["lat"] = location!.coordinate.latitude
            params["lon"] = location!.coordinate.longitude
        }
        
        PFCloud.callFunctionInBackground("queryMatches", withParameters: params) { (results, error) -> Void in
            print("results: \(results)")
            let matches: [PFObject]? = results as? [PFObject]
            completion(results: matches, error: error)
        }
    }
    */
    
    class func inviteMatch(fromMatch: PFObject, toMatch: PFObject, completion: ((results: AnyObject?, error: NSError?) -> Void)) {
        PFCloud.callFunctionInBackground("inviteMatch", withParameters: ["from": fromMatch.objectId!, "to": toMatch.objectId!]) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results: results, error: error)
        }
    }

    class func cancelMatch(match: PFObject, completion: ((results: AnyObject?, error: NSError?)->Void)) {
        PFCloud.callFunctionInBackground("cancelMatch", withParameters: ["match": match.objectId!]) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results: results, error: error)
        }
    }

    class func respondToInvite(fromMatch: PFObject, toMatch: PFObject, responseType: String?, completion: ((results: AnyObject?, error: NSError?)->Void)) {
        var params =  ["from": fromMatch.objectId!, "to": toMatch.objectId!]
        if responseType != nil {
            params["responseType"] = responseType
        }
        PFCloud.callFunctionInBackground("respondToInvite", withParameters: params) { (results, error) -> Void in
            print("results: \(results) error: \(error)")
            completion(results: results, error: error)
        }
    }
}
