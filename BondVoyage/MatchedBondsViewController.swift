//
//  MatchedBondsViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 3/29/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class MatchedBondsViewController: RequestedBondsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setup() {
        
        activities.removeAll()
        ActivityRequest.queryActivities(PFUser.currentUser(), joining: false, categories: nil, location: nil, distance: nil, aboutSelf: nil, aboutOthers: []) { (results, error) -> Void in
            // returns activities where the owner of the activity is the user
            if results != nil {
                if results!.count > 0 {
                    for activity: PFObject in results! {
                        if activity.isAcceptedActivity() {
                            self.activities.append(activity)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
            if error != nil && error!.code == 209 {
                self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                    PFUser.logOut()
                    NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
                })
                return
            }
        }
        ActivityRequest.queryActivities(PFUser.currentUser(), joining: true, categories: nil, location: nil, distance: nil, aboutSelf: nil, aboutOthers: []) { (results, error) -> Void in
            // returns activities where the owner is not the user but is in the joining list
            if results != nil {
                if results!.count > 0 {
                    for activity: PFObject in results! {
                        if activity.isAcceptedActivity() {
                            self.activities.append(activity)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
            if error != nil && error!.code == 209 {
                self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                    PFUser.logOut()
                    NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
                })
                return
            }
        }
    }
}
