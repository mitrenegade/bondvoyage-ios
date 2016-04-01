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
        ActivityRequest.queryMatchedActivities(PFUser.currentUser()) { (results, error) in
            if error != nil {
                return
            }
            self.refreshBadgeCount(.TAB_MATCHED_BONDS, activities: results)
        }
        
        ActivityRequest.getRequestedBonds { (results, error) in
            if error != nil {
                return
            }
            self.refreshBadgeCount(.TAB_REQUESTED_BONDS, activities: results)
        }
    }

    func refreshBadgeCount(tabIndex: TabIndex, activities: [PFObject]?) {
        if tabIndex != .TAB_REQUESTED_BONDS && tabIndex != .TAB_MATCHED_BONDS {
            return
        }
        let tabBarItem = self.tabBar.items![tabIndex.rawValue]
        if activities == nil {
            tabBarItem.badgeValue = nil
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
        for activity: PFObject in activities! {
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
        
        if ct > 0 {
            tabBarItem.badgeValue = "\(ct)"
        }
        else {
            tabBarItem.badgeValue = nil
        }
    }
}
