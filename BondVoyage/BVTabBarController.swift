//
//  BVTabBarController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 4/1/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class BVTabBarController: UITabBarController {
    enum TabIndex: Int {
        case TAB_CATEGORIES = 0
        case  TAB_REQUESTED_BONDS = 1
        case TAB_MATCHED_BONDS = 2
    }
    
    var bondReceivedTimestamp: NSDate? // timestamp for last time requestedBonds were received
    var matchReceivedTimestamp: NSDate? // timestamp for last time matchedBonds were received

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.refreshNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshNotifications() {
    }

    // MARK: RequestedBonds
    let REQUEST_TIMESTAMP_INTERVAL = NSTimeInterval(-10*60) // 10 minutes
    let NOTIFICATION_TIMESTAMP_INTERVAL = NSTimeInterval(-2*60*60) // 2 hours
    
    func needsUpdateRequestedBonds() -> Bool {
        if self.bondReceivedTimestamp == nil || self.bondReceivedTimestamp!.timeIntervalSinceNow < REQUEST_TIMESTAMP_INTERVAL {
            // no timestamp, or 10 minutes old
            return true
        }
        return false
    }

    func refreshBadgeCount(tabIndex: TabIndex, activities: [PFObject]) {
        if tabIndex != .TAB_REQUESTED_BONDS && tabIndex != .TAB_MATCHED_BONDS {
            return
        }
        var key: String
        if tabIndex == .TAB_REQUESTED_BONDS {
            key = "requestedBond:seen:"
        }
        else {
            key = "matchedBond:seen:"
        }
        var ct = 0
        for activity: PFObject in activities {
            let id = activity.objectId!
            key = "\(key)\(id)"
            if NSUserDefaults.standardUserDefaults().objectForKey(key) != nil && NSUserDefaults.standardUserDefaults().objectForKey(key) as! Bool == true {
                continue
            }
            let created = activity.objectForKey("time") as! NSDate
            if created.timeIntervalSinceNow <= -6000*60 {
                continue
            }
            ct = ct + 1
        }
        
        let tabBarItem = self.tabBar.items![tabIndex.rawValue]
        if ct > 0 {
            tabBarItem.badgeValue = "\(ct)"
        }
        else {
            tabBarItem.badgeValue = nil
        }
    }
    
    func needsUpdateMatchedBonds() -> Bool {
        if self.bondReceivedTimestamp == nil || self.matchReceivedTimestamp!.timeIntervalSinceNow < REQUEST_TIMESTAMP_INTERVAL {
            // no timestamp, or 10 minutes old
            return true
        }
        return false
    }
    
    
}
