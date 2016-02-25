//
//  MyActivitiesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/24/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class MyActivitiesViewController: HereAndNowViewController {
    
    var myActivities: [PFObject]?
    var myJoiningActivities: [PFObject]?


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setup() {
        self.loadActivitiesForCategory(nil, user: PFUser.currentUser(), joining: false) { (results, error) -> Void in
            if results != nil {
                if results!.count > 0 {
                    self.myActivities = results
                    self.tableView.reloadData()
                    self.hideCategories()
                }
            }
        }
        self.loadActivitiesForCategory(nil, user: PFUser.currentUser(), joining: true) { (results, error) -> Void in
            if results != nil {
                if results!.count > 0 {
                    self.myJoiningActivities = results
                    self.tableView.reloadData()
                    self.hideCategories()
                }
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My activities"
        }
        else {
            return "Activities I'm joining"
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier)! as! ActivitiesCell
        cell.adjustTableViewCellSeparatorInsets(cell)
        if indexPath.section == 0 && self.myActivities != nil {
            cell.configureCellForUser(self.myActivities![indexPath.row])
        }
        else if indexPath.section == 1 && self.myJoiningActivities != nil {
            cell.configureCellForUser(self.myJoiningActivities![indexPath.row])
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.myActivities == nil {
                return 0
            }
            return self.myActivities!.count
        }
        else {
            if self.myJoiningActivities == nil {
                return 0
            }
            return self.myJoiningActivities!.count
        }
    }
    
    func add(category: String?) {
        self.createActivity(category!, completion: { (result, error) -> Void in
            self.toggleCategories(false)
            if result != nil {
                let activity: PFObject = result!
                self.goToCurrentActivity(activity)
                self.view.endEditing(true)
            }
            else {
                self.simpleAlert("Could not create activity", defaultMessage: "We could not create an activity for \(category!)", error: error)
            }
        })
    }
    
    func goToCurrentActivity (activity: PFObject) {
        self.hideCategories()
        self.currentActivity = activity
        self.performSegueWithIdentifier("GoToCurrentActivity", sender: self)
    }

    func createActivity(category: String, completion: ((result: PFObject?, error: NSError?)->Void)) {
        if PFUser.currentUser() == nil {
            completion(result: nil, error: nil)
            return
        }
        if self.currentLocation == nil {
            if TESTING {
                self.currentLocation = CLLocation(latitude: PHILADELPHIA_LAT, longitude: PHILADELPHIA_LON)
            }
            else {
                self.warnForLocationAvailability()
                completion(result: nil, error: nil)
                return
            }
        }
        // no existing requests exist. Create a request for others to match to
        let categories: [String] = [category]
        ActivityRequest.createActivity(categories, location: self.currentLocation!) { (result, error) -> Void in
            self.currentActivity = result
            completion(result: result, error: error)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToActivityDetail" {
            let controller: ActivityDetailViewController = segue.destinationViewController as! ActivityDetailViewController
            controller.activity = sender as! PFObject
            controller.isRequestingJoin = false
        }
    }
}
