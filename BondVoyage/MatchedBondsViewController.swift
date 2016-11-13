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
        self.tabIndex = .tab_MATCHED_BONDS
    }
    
    override func setupWithCompletion( _ completion: (()->Void)? ) {
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        activities.removeAll()
        self.labelNoBonds.isHidden = true
        ActivityRequest.queryMatchedActivities(PFUser.current()) { (results, error) in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
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
                self.activities.append(contentsOf: results!)
                self.navigationItem.rightBarButtonItem?.isEnabled = true
                if self.activities.count == 0 {
                    self.labelNoBonds.text = "There are currently no matched bonds for you."
                    self.labelNoBonds.isHidden = false
                }
                self.tableView.reloadData()
                if completion != nil {
                    completion!()
                }
            }
        }
    }
    
    override func goToActivity(_ activity: PFObject) {
        // TODO: delete
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
