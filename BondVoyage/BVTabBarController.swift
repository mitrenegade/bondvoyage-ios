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
    case TAB_CATEGORIES = 0
    case  TAB_REQUESTED_BONDS = 1
    case TAB_MATCHED_BONDS = 2
}

let TAB_NOTIFICATION_AGE = NSTimeInterval(-24*60*60)
class BVTabBarController: UITabBarController {
    
    var bondReceivedTimestamp: NSDate? // timestamp for last time requestedBonds were received
    var matchReceivedTimestamp: NSDate? // timestamp for last time matchedBonds were received

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.refreshNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshNotifications", name: "activity:updated", object: nil)
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

    func refreshBadgeCount(tabIndex: BVTabIndex, activities: [PFObject]?) {
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
            let newkey = "\(key)\(id)"
            if NSUserDefaults.standardUserDefaults().objectForKey(newkey) != nil && NSUserDefaults.standardUserDefaults().objectForKey(newkey) as! Bool == true {
                continue
            }
            
            // don't show notifications if they are more than a day old
            let created = activity.objectForKey("time") as! NSDate
            if created.timeIntervalSinceNow <= TAB_NOTIFICATION_AGE {
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
