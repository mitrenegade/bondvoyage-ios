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
    
    class func createMatch(categories: [String], completion: ((result: PFObject?, error: NSError?)->Void)) {
        PFCloud.callFunctionInBackground("createMatchRequest", withParameters: ["categories": categories]) { (results, error) -> Void in
            print("results: \(results)")
            let match: PFObject? = results as? PFObject
            completion(result: match, error: error)
        }
    }

    class func queryMatches(location: NSObject?, categories: [String], completion: ((results: [PFObject]?, error: NSError?)->Void)) {
        
        PFCloud.callFunctionInBackground("queryMatches", withParameters: ["categories": categories]) { (results, error) -> Void in
            print("results: \(results)")
            let matches: [PFObject]? = results as? [PFObject]
            completion(results: matches, error: error)
        }
    }

    
}
