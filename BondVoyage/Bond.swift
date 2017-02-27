//
//  Bond.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/4/17.
//  Copyright © 2017 RenderApps. All rights reserved.
//

import UIKit
import Parse

class Bond: PFObject {
    @NSManaged var invited: [String]?
    @NSManaged var category: String?
    @NSManaged var accepted: [String]?
}

extension Bond: PFSubclassing {
    static func parseClassName() -> String {
        return "Bond"
    }
}

extension Bond {
    
    class func inviteToBond(category: CATEGORY, inviteeId: String, completion: ((_ bond: Bond?, _ conversation: Conversation?, _ error: NSError?) -> Void)?) {

        guard let user = PFUser.current(), let userId = user.objectId else { return }
        guard let query: PFQuery<Bond> = Bond.query() as? PFQuery<Bond> else { return }
        
        query.whereKey("category", equalTo: category.rawValue.lowercased())
        query.whereKey("invited", containsAllObjectsIn: [inviteeId, userId])
        query.findObjectsInBackground { (results, error) in
            if let results = results {
                let bond = results.count == 0 ? Bond() : results[0]
                bond.invited = [inviteeId, userId]
                var accepted = bond.accepted ?? []
                if !accepted.contains(userId) {
                    accepted.append(userId)
                }
                bond.accepted = accepted
                bond.category = category.rawValue.lowercased()
                bond.saveInBackground(block: { (success, error) in
                    if success {
                        if let accepted = bond.accepted, accepted.contains(userId) && accepted.contains(inviteeId) {
                            self.createConversationForBond(bond: bond, userId: inviteeId, completion: { (conversation, error) in
                                completion?(nil, conversation, error)
                            })
                        }
                        else {
                            completion?(bond, nil, error as? NSError)
                        }
                    }
                    else {
                        completion?(nil, nil, error as? NSError)
                    }
                })
            }
            else {
                print("error: \(error)")
                completion?(nil, nil, error as? NSError)
            }
        }

    }
    
    class func createConversationForBond(bond: Bond, userId: String, completion: ((_ conversation: Conversation?, _ error: NSError?) -> Void)?) {
        
        PFCloud.callFunction(inBackground: "v4createConversationForBond", withParameters: ["userId": userId, "bondId": bond.objectId!]) { (results, error) -> Void in
            if let conversation = results as? Conversation {
                completion?(conversation, nil)
            }
            else {
                completion?(nil, error as? NSError)
            }
        }
    }
}
