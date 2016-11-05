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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabIndex = .TAB_MATCHED_BONDS
    }
    
    override func setupWithCompletion( completion: (()->Void)? ) {
        self.navigationItem.rightBarButtonItem?.enabled = false
        activities.removeAll()
        self.labelNoBonds.hidden = true
        ActivityRequest.queryMatchedActivities(PFUser.currentUser()) { (results, error) in
            self.navigationItem.rightBarButtonItem?.enabled = true
            if error != nil {
                if error!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                        UserService.logout()
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
                if self.activities.count == 0 {
                    self.labelNoBonds.text = "There are currently no matched bonds for you."
                    self.labelNoBonds.hidden = false
                }
                self.tableView.reloadData()
                if completion != nil {
                    completion!()
                }
            }
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
}
