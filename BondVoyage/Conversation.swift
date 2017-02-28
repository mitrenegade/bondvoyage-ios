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
    @NSManaged var unreadIds: [Any]? // userId in here will see this as a newly updated conversation
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
    class func queryConversations(unread: Bool = false, completion: ((_ results: [Conversation]?, _ error: NSError?)->Void)?) {
        print("Load chats")
        guard let user = PFUser.current() as? User, let userId = user.objectId else { return }
        guard let query: PFQuery<Conversation> = Conversation.query() as? PFQuery<Conversation> else { return }
        query.whereKey("participantIds", contains: userId)
        if unread {
            query.whereKey("unreadIds", contains: userId)
        }
        query.findObjectsInBackground { (results, error) in
            completion?(results, error as? NSError)
        }

    }
    
    class func withId(objectId: String, completion: @escaping ((Conversation?)->Void)) {
        let query = Conversation.query()
        query?.getObjectInBackground(withId: objectId, block: { (result, error) in
            completion(result as? Conversation)
        })
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

    func queryOtherUser(completion: @escaping ((_ user: User?, _ error: NSError?) -> Void)) {
        guard var userIds = self.participantIds as? [String] else {
            return
        }
        guard let currentUser = PFUser.current(), let currentUserId = currentUser.objectId else { return }
        if let index = userIds.index(of: currentUserId) {
            userIds.remove(at: index)
        }
        guard userIds.count > 0, let userId = userIds.first else { return }
        
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: userId)
        query?.findObjectsInBackground(block: { (results, error) in
            if let error = error {
                print("error \(error)")
                completion(nil, error as NSError?)
                return
            }
            
            if let users = results as? [PFUser], users.count > 0, let user = users.first as? User {
                completion(user, nil)
            }
            else {
                print("no user found")
                // handle error
                completion(nil, nil)
            }
        })

    }
}

