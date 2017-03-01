//
//  BVTabBarController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 4/1/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

enum BVTabIndex: Int {
    case browser = 0
    case  messages = 1
}

let TAB_NOTIFICATION_AGE = TimeInterval(-24*60*60)
class BVTabBarController: UITabBarController {
    
    var bondReceivedTimestamp: Date? // timestamp for last time requestedBonds were received
    var matchReceivedTimestamp: Date? // timestamp for last time matchedBonds were received
    var promptedForPush: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.refreshNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(BVTabBarController.refreshNotifications), name: NSNotification.Name(rawValue: "conversations:updated"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.current() != nil && !self.promptedForPush {
            if !self.appDelegate().hasPushEnabled() {
                // prompt for it
                self.appDelegate().promptForRemoteNotifications()
            }
            else {
                // reregister
                self.appDelegate().initializeNotificationServices()
            }
            self.promptedForPush = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshNotifications() {
        let tabBarItem = self.tabBar.items![BVTabIndex.messages.rawValue]
        tabBarItem.badgeValue = nil

        Conversation.queryConversations(unread: true) { (results, error) in
            if let conversations = results {
                let ct = conversations.count
                if ct > 0 {
                    tabBarItem.badgeValue = "\(ct)"
                }
            }
        }
    }
}
