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
    case tab_CATEGORIES = 0
    case  tab_REQUESTED_BONDS = 1
    case tab_MATCHED_BONDS = 2
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
        NotificationCenter.default.addObserver(self, selector: #selector(BVTabBarController.refreshNotifications), name: NSNotification.Name(rawValue: "activity:updated"), object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.current() != nil && !self.promptedForPush {
            if !self.appDelegate().hasPushEnabled() {
                // prompt for it
                self.appDelegate().registerForRemoteNotifications()
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
        // NOT USED
        ActivityService.queryMatchedActivities(PFUser.current()) { (results, error) in
            if error != nil {
                return
            }
            self.refreshBadgeCount(.tab_MATCHED_BONDS, activities: results)
        }
        
        ActivityService.getRequestedBonds { (results, error) in
            if error != nil {
                return
            }
            self.refreshBadgeCount(.tab_REQUESTED_BONDS, activities: results)
        }
    }

    func refreshBadgeCount(_ tabIndex: BVTabIndex, activities: [PFObject]?) {
        if tabIndex != .tab_REQUESTED_BONDS && tabIndex != .tab_MATCHED_BONDS {
            return
        }
        let tabBarItem = self.tabBar.items![tabIndex.rawValue]
        if activities == nil {
            tabBarItem.badgeValue = nil
            return
        }

        var key: String
        if tabIndex == .tab_REQUESTED_BONDS {
            key = "requestedBond:seen:"
        }
        else {
            key = "matchedBond:seen:"
        }
        var ct = 0
        for activity: PFObject in activities! {
            let id = activity.objectId!
            let newkey = "\(key)\(id)"
            if UserDefaults.standard.object(forKey: newkey) != nil && UserDefaults.standard.object(forKey: newkey) as! Bool == true {
                continue
            }
            
            // don't show notifications if they are more than a day old
            let created = activity.object(forKey: "time") as! Date
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
