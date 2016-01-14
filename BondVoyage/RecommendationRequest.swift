//
//  RecommendationRequest.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/14/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class RecommendationRequest: NSObject {
    class func seed() {
        // private function for testing purposes only
        PFCloud.callFunctionInBackground("seedTestRecommendations", withParameters: nil) { (results, error) -> Void in
            if error != nil {
                print("seedTestRecommendations error: \(error)")
            }
            else {
                print("seedTestRecommendations results: \(results)")
            }
        }
    }

    // query for all recommendations - does not use Parse yet
    // todo: add CLLocation or other parameters
    class func recommendationsQuery(location: NSObject?, interests: [String], completion: ((results: [PFObject]?, error: NSError?)->Void)) {

        // TODO: call queryUsers; handle nil or unspecified default search criteria
        PFCloud.callFunctionInBackground("queryRecommendations", withParameters: ["interests": interests]) { (results, error) -> Void in
            print("results: \(results)")
            let recommendations: [PFObject]? = results as? [PFObject]
            completion(results: recommendations, error: error)
        }
    }

}
