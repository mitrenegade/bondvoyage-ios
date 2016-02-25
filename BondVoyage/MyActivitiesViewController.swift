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

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setup() {
        self.loadActivitiesForCategory(nil, user: PFUser.currentUser()) { (results, error) -> Void in
            if results != nil {
                if results!.count > 0 {
                    
                    if self.selectedCategory == nil {
                        self.nearbyActivities = results
                    }
                    else {
                        self.filteredActivities = results
                    }
                    self.tableView.reloadData()
                    self.hideCategories()
                }
                else {
                    // no results, no error
                    var message = ""
                    if self.selectedCategory == nil {
                        message = "There are no activities near you."
                        self.nearbyActivities = nil
                        self.tableView.reloadData()
                    }
                    else {
                        message = "There is no one interested in \(self.selectedCategory!) near you."
                        self.filteredActivities = nil
                    }
                    
                    if PFUser.currentUser() != nil {
                        message = "\(message) Click the button to add your own activity."
                    }
                    
                    self.tableView.reloadData()
                    self.hideCategories()
                    
                    self.simpleAlert("No activities nearby", message:message)
                }
            }
            else {
                let message = "There was a problem loading matches. Please try again"
                self.simpleAlert("Could not select category", defaultMessage: message, error: error)
            }
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
