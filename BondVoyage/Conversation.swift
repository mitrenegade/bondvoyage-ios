//
//  Conversation.swift
//  BondVoyage
//
//  Created by Bobby Ren on 11/21/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class Conversation: PFObject {
    @NSManaged var dialogId: String?
    
    @NSManaged var participantIds: [Any]? // a pair of pfObjectIds
    @NSManaged var activityIds: [Any]?
}

extension Conversation: PFSubclassing {
    static func parseClassName() -> String {
        return "Conversation"
    }
}

extension Conversation {
    convenience init(userId1: String, userId2: String, dialogId: String) {
        self.init()
        
        self.participantIds = [userId1, userId1]
        self.dialogId = dialogId
    }
    
    class func loadConversations(user: PFUser, completion: ((_ results: [Conversation]?, _ error: NSError?)->Void)?) {
        
    }
}

