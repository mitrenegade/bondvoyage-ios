//
//  RecommendationRequest.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/14/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

var recommendations: [[String: AnyObject]] = [
    ["id": 1, "imageName":"event_concert", "title": "Free concert", "details": "Attend a free concert featuring the music of David Bowie"],
    ["id": 2, "imageName":"event_ducktours", "title": "BOGO Duck Tours", "details": "See the city from land and sea! Bring a friend"],
    ["id": 3, "imageName":"event_starbucks", "title": "Free dessert with coffee", "details": "Drink Starbucks and get a scone with that latte"],
    ["id": 4, "imageName":"event_hamilton", "title": "Hamilton tickets", "details": "Rush tickets still available"],
    ["id": 5, "imageName":"event_karaoke", "title": "Karaoke", "details": "Get one free drink at the karaoke lounge"],
    ["id": 6, "imageName":"event_sushi", "title": "Sushi", "details": "Half off sake bombs and hand rolls"],
    ["id": 7, "imageName":"event_salsa", "title": "Salsa at Ryles", "details": "Free beginner lessons at 9 PM"],
    ["id": 8, "imageName":"event_legalseafoods", "title": "Legal Seafoods", "details": "Experience Boston's famous Lobsta roll"],
]

class RecommendationRequest: NSObject {
    // query for all recommendations - does not use Parse yet
    // todo: add CLLocation or other parameters
    class func recommendationsQuery(location: NSObject?, count: Int, completion: ((results: [[String: AnyObject]]?, error: NSError?)->Void)) {

        let totalToGenerate = Int(arc4random_uniform(UInt32(count)))
        var idArray: [Int] = [Int]()
        var allRecommended: [[String: AnyObject]] = [[String: AnyObject]]()
        
        repeat {
            let index = Int(arc4random_uniform(UInt32(recommendations.count)))
            if !idArray.contains(index) {
                idArray.append(index)
                
                allRecommended.append(recommendations[index])
            }
        }
        while allRecommended.count < totalToGenerate && allRecommended.count < recommendations.count
        
        completion(results: allRecommended, error: nil)
    }

}
