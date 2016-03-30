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
    var myActivitiesLoaded: Bool = false
    var otherActivitiesLoaded: Bool = false
    var loadingError: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setup() {
        self.navigationItem.rightBarButtonItem?.enabled = false
        activities.removeAll()
        self.myActivitiesLoaded = false
        self.otherActivitiesLoaded = false
        self.loadingError = nil
        ActivityRequest.queryActivities(PFUser.currentUser(), joining: false, categories: nil, location: nil, distance: nil, aboutSelf: nil, aboutOthers: []) { (results, error) -> Void in
            // returns activities where the owner of the activity is the user
            if results != nil {
                if results!.count > 0 {
                    for activity: PFObject in results! {
                        if activity.isAcceptedActivity() {
                            self.activities.append(activity)
                        }
                    }
                }
            }
            self.myActivitiesLoaded = true
            self.reloadTableIfReady(error)
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
                }
            }
            self.otherActivitiesLoaded = true
            self.reloadTableIfReady(error)
            
        }
    }
    
    func reloadTableIfReady(error: NSError?) {
        if error != nil {
            self.loadingError = error
        }
        
        if self.myActivitiesLoaded && self.otherActivitiesLoaded {
            self.navigationItem.rightBarButtonItem?.enabled = true
            if self.loadingError != nil {
                if self.loadingError!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                        PFUser.logOut()
                        NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
                    })
                    return
                }
                else {
                    self.simpleAlert("Could not load matches", defaultMessage: "Please click refresh to try again.", error: self.loadingError)
                }
            }
            else {
                self.tableView.reloadData()
            }
        }
    }
}
