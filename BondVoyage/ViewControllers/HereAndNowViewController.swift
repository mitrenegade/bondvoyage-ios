//
//  HereAndNowViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/23/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit
import Parse
import AsyncImageView
import ParseUI
import GoogleMaps

let date = NSDate()
let calendar = NSCalendar.currentCalendar()
let components = calendar.components([.Day , .Month , .Year], fromDate: date)

let kCellIdentifier = "ActivitiesCell"

class HereAndNowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchCategoriesDelegate, CLLocationManagerDelegate {

    // categories dropdown
    @IBOutlet weak var constraintCategoriesHeight: NSLayoutConstraint!
    var categoriesVC: SearchCategoriesViewController!
    var showingCategories: Bool = false
    
    // search results
    @IBOutlet weak var tableView: UITableView!
    var selectedUser: PFUser?
    var recommendations: [PFObject]?
    
    // tableview data
    var selectedCategory: String?
    var nearbyActivities: [PFObject]?
    var filteredActivities: [PFObject]?
    
    // from SearchCategoriesDelegate
    var currentActivity: PFObject?
    
    var promptedForPush: Bool = false
    
    // location
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    var placePicker: GMSPlacePicker?

    override func viewDidLoad() {
        super.viewDidLoad()
        // configure title bar
        let imageView: UIImageView = UIImageView(image: UIImage(named: "logo-plain")!)
        imageView.frame = CGRectMake(0, 0, 150, 44)
        imageView.contentMode = .ScaleAspectFit
        imageView.backgroundColor = Constants.lightBlueColor()
        imageView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, 22)
        self.navigationController!.navigationBar.addSubview(imageView)

        self.setup()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.currentUser() != nil && !self.promptedForPush {
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
    
    func setup() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "didClickButton:")
        self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()
        
        self.constraintCategoriesHeight.constant = 0

        self.didSelectCategory(nil)
        
        // location
        locationManager.delegate = self
        let loc: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if loc == CLAuthorizationStatus.AuthorizedAlways || loc == CLAuthorizationStatus.AuthorizedWhenInUse{
            locationManager.startUpdatingLocation()
        }
        else if loc == CLAuthorizationStatus.Denied {
            self.warnForLocationPermission()
        }
        else {
            if (locationManager.respondsToSelector("requestWhenInUseAuthorization")) {
                locationManager.requestWhenInUseAuthorization()
            }
            else {
                locationManager.startUpdatingLocation()
            }
        }
    }

    // MARK: - API
    func loadActivitiesForCategory(category: String?, user: PFUser?, joining: Bool?, completion: ((results: [PFObject]?, error: NSError?)->Void)) {
        var cat: [String]?
        if category != nil {
            cat = [category!]
        }
        ActivityRequest.queryActivities(self.currentLocation, user: user, joining: joining, categories: cat) { (results, error) -> Void in
            completion(results: results, error: error)
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier)! as! ActivitiesCell
        cell.adjustTableViewCellSeparatorInsets(cell)
        if self.selectedCategory == nil && nearbyActivities != nil {
            cell.configureCellForUser(self.nearbyActivities![indexPath.row])
        }
        else if self.selectedCategory != nil && filteredActivities != nil {
            cell.configureCellForUser(self.filteredActivities![indexPath.row])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if self.selectedCategory != nil {
            if let count: Int = self.filteredActivities?.count {
                rows = count
            }
            else {
                rows = 0
            }
        }
        else {
            if let count: Int = self.nearbyActivities?.count {
                rows = count
            }
            else {
                print("No matches found")
                rows = 0
            }
        }
        print("rows: \(rows)")
        return rows
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 180
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if PFUser.currentUser() == nil {
            self.simpleAlert("Please log in", message: "Log in or create an account to view someone's profile")
            return
        }
        
        let activity: PFObject = self.nearbyActivities![indexPath.row]
        self.goToActivity(activity)
    }
    
    func toggleCategories(show: Bool) {
        if show {
            self.showingCategories = true
            self.constraintCategoriesHeight.constant = self.view.frame.size.height
            self.categoriesVC.tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
            self.view.setNeedsLayout()
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
        else {
            self.hideCategories()
            self.didSelectCategory(nil)
        }
    }
    
    func hideCategories() {
        self.showingCategories = false
        self.constraintCategoriesHeight.constant = 0
        // don't animate or tableview looks weird
    }

    // MARK: - SearchCategoriesDelegate
    func didSelectCategory(category: String?) {
        // first query for existing bond requests
        self.selectedCategory = category
        self.loadActivitiesForCategory(category?.lowercaseString, user: nil, joining: false) { (results, error) -> Void in
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
    
    func goToActivity(activity: PFObject) {
        if self.currentLocation == nil || self.currentLocation!.horizontalAccuracy >= 100 {
            if TESTING {
                self.currentLocation = CLLocation(latitude: PHILADELPHIA_LAT, longitude: PHILADELPHIA_LON)
            }
            else {
                self.warnForLocationAvailability()
                return
            }
        }
        self.performSegueWithIdentifier("GoToActivityDetail", sender: activity)
    }
    
    /* NOT USED
    func goToCategory(activities: [PFObject], index: Int) {
        if self.currentLocation == nil || self.currentLocation!.horizontalAccuracy >= 100 {
            if TESTING {
                self.currentLocation = CLLocation(latitude: PHILADELPHIA_LAT, longitude: PHILADELPHIA_LON)
            }
            else {
                self.warnForLocationAvailability()
                return
            }
        }
        
        self.hideCategories()
        let activity: PFObject = activities[index]
        var mutable: [PFObject] = activities
        mutable.removeAtIndex(index)
        mutable.insert(activity, atIndex: 0)
        self.performSegueWithIdentifier("GoToNearbyActivities", sender: mutable)
    }
    */
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "embedCategoriesVCSegue" {
            self.categoriesVC = segue.destinationViewController as! SearchCategoriesViewController
            self.categoriesVC.delegate = self
        }
        else if segue.identifier == "GoToActivityDetail" {
            let controller: ActivityDetailViewController = segue.destinationViewController as! ActivityDetailViewController
            controller.activity = sender as! PFObject
            controller.isRequestingJoin = true
        }
        else if segue.identifier == "GoToNearbyActivities" {
            let controller: InviteViewController = segue.destinationViewController as! InviteViewController
            let activities: [PFObject] = sender as! [PFObject]
            controller.activities = activities
        }
        else if segue.identifier == "GoToCurrentActivity" {
            let controller: MatchStatusViewController = segue.destinationViewController as! MatchStatusViewController
            controller.currentActivity = self.currentActivity
        }
    }
    
    // MARK: location
    func warnForLocationPermission() {
        let message: String = "BondVoyage needs GPS access to find activities near you. Please go to your phone settings to enable location access. Go there now?"
        let alert: UIAlertController = UIAlertController(title: "Could not access location", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func warnForLocationAvailability() {
        let message: String = "BondVoyage needs an accurate location to find a match. Please make sure your phone can receive accurate location information."
        let alert: UIAlertController = UIAlertController(title: "Accurate location not found", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Close", style: .Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            locationManager.startUpdatingLocation()
        }
        else if status == .Denied {
            self.warnForLocationPermission()
            print("Authorization is not available")
        }
        else {
            print("status unknown")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first as CLLocation? {
            print("\(location)")
            self.currentLocation = location
        }
    }
    
    // MARK: add button
    @IBAction func didClickButton(sender: UIButton) {
        self.toggleCategories(!self.showingCategories)
    }
}
