//
//  MatchedBondsViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 3/29/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse
import PKHUD

class MatchedBondsViewController: RequestedBondsViewController {
    var myActivitiesLoaded: Bool = false
    var otherActivitiesLoaded: Bool = false
    var loadingError: NSError?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func setupWithCompletion( completion: (()->Void)? ) {
        self.navigationItem.rightBarButtonItem?.enabled = false
        activities.removeAll()
        self.myActivitiesLoaded = false
        self.otherActivitiesLoaded = false
        self.loadingError = nil
        HUD.show(.SystemActivity)
        /*
        ActivityRequest.getMyMatchedBonds { (results, error) in
            if results != nil {
                self.activities.appendContentsOf(results!)
            }
            self.myActivitiesLoaded = true
            self.reloadTableIfReady(error, completion: completion)
        }
        ActivityRequest.getBondsMatchedWithMe { (results, error) in
            if results != nil {
                self.activities.appendContentsOf(results!)
            }
            self.otherActivitiesLoaded = true
            self.reloadTableIfReady(error, completion: completion)
        }
        */
        ActivityRequest.queryMatchedActivities(PFUser.currentUser()) { (results, error) in
            self.navigationItem.rightBarButtonItem?.enabled = true
            if error != nil {
                HUD.hide(animated: false)
                if error!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                        PFUser.logOut()
                        NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
                    })
                    if completion != nil {
                        completion!()
                    }
                    return
                }
                else {
                    self.simpleAlert("Could not load matches", defaultMessage: "Please click refresh to try again.", error: error)
                    if completion != nil {
                        completion!()
                    }
                }
            }
            else if results != nil {
                self.activities.appendContentsOf(results!)
                self.navigationItem.rightBarButtonItem?.enabled = true
                HUD.hide(animated: true, completion: { (success) -> Void in
                    if self.activities.count == 0 {
                        self.simpleAlert("No matches yet", message: "There are currently no matched bonds for you.")
                    }
                    self.tableView.reloadData()
                    if completion != nil {
                        completion!()
                    }
                })
            }
        }
    }
    
    func reloadTableIfReady(error: NSError?, completion: ( ()->Void)? ) {
        if error != nil {
            self.loadingError = error
        }
        
        if self.myActivitiesLoaded && self.otherActivitiesLoaded {
            self.navigationItem.rightBarButtonItem?.enabled = true
            HUD.hide(animated: true, completion: { (success) -> Void in
                if self.loadingError != nil {
                    if self.loadingError!.code == 209 {
                        self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                            PFUser.logOut()
                            NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
                        })
                        if completion != nil {
                            completion!()
                        }
                        return
                    }
                    else {
                        self.simpleAlert("Could not load matches", defaultMessage: "Please click refresh to try again.", error: self.loadingError)
                        if completion != nil {
                            completion!()
                        }
                    }
                }
                else {
                    if self.activities.count == 0 {
                        self.simpleAlert("No matches yet", message: "There are currently no matched bonds for you.")
                    }
                    self.tableView.reloadData()
                    if completion != nil {
                        completion!()
                    }
                }
            })
        }
    }
    
    override func goToActivity(activity: PFObject) {
        self.performSegueWithIdentifier("GoToActivityDetail", sender: activity)
        self.tableView.userInteractionEnabled = true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToActivityDetail" {
            let controller: ActivityDetailViewController = segue.destinationViewController as! ActivityDetailViewController
            controller.activity = sender as! PFObject
            controller.isRequestingJoin = false
        }
    }

    override func refreshBadgeCount() {
        var ct = 0
        for activity: PFObject in self.activities {
            let id = activity.objectId!
            let key = "matchedBond:seen:\(id)"
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
            self.navigationController?.tabBarItem.badgeValue = "\(ct)"
        }
        else {
            self.navigationController?.tabBarItem.badgeValue = nil
        }
    }
}
