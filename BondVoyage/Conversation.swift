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

    @NSManaged var category: String?
    @NSManaged var city: String?
}

extension Conversation: PFSubclassing {
    static func parseClassName() -> String {
        return "Conversation"
    }
}

extension Conversation {
    class func loadConversations(user: PFUser, completion: ((_ results: [Conversation]?, _ error: NSError?)->Void)?) {
        
    }
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM d, yyyy"
        return df
    }

    var dateString: String {
        guard let date = self.updatedAt else { return "Today" }
        let beginningOfDay = Calendar.current.startOfDay(for: NSDate() as Date)
        if date.timeIntervalSince(beginningOfDay) > 0 {
            return "Today"
        }
        return dateFormatter.string(from: date)
    }
    
    var lastMessage: String {
        // todo
        return "Hello"
    }

}

