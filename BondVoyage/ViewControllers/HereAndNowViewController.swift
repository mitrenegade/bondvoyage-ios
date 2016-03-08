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
    
    // tableview data
    var selectedSubcategory: String?
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
        self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateActivities", name: "activity:updated", object: nil)
        
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
        
        self.constraintCategoriesHeight.constant = 0

        self.didSelectCategory(nil, category: nil)
        
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
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier)! as! ActivitiesCell
        cell.adjustTableViewCellSeparatorInsets(cell)
        if self.selectedSubcategory == nil && nearbyActivities != nil {
            cell.configureCellForUser(self.nearbyActivities![indexPath.row])
        }
        else if self.selectedSubcategory != nil && filteredActivities != nil {
            cell.configureCellForUser(self.filteredActivities![indexPath.row])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if self.selectedSubcategory != nil {
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
        
        if self.selectedSubcategory == nil {
            let activity: PFObject = self.nearbyActivities![indexPath.row]
            self.goToActivity(activity)
        }
        else {
            let activity: PFObject = self.filteredActivities![indexPath.row]
            self.goToActivity(activity)
        }
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
            self.didSelectCategory(nil, category: nil)
        }
    }
    
    func hideCategories() {
        self.showingCategories = false
        self.constraintCategoriesHeight.constant = 0
        // don't animate or tableview looks weird
    }

    // MARK: - SearchCategoriesDelegate
    func didSelectCategory(subcategory: String?, category: String?) {
        // first query for existing bond requests
        self.selectedSubcategory = subcategory
        var cat: [String]?
        if subcategory != nil {
            // a specific subcategory
            cat = [subcategory!]
        }
        else if category != nil {
            // All in a category
            let subcategories: [SUBCATEGORY] = SUBCATEGORIES[CategoryFactory.categoryForString(category!)!]!
            cat = subcategories.map({ (subcategory) -> String in
                return subcategory.rawValue.lowercaseString
            })
        }
        ActivityRequest.queryActivities(self.currentLocation, user: nil, joining: false, categories: cat) { (results, error) -> Void in
            if results != nil {
                if results!.count > 0 {
                    
                    if self.selectedSubcategory == nil {
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
                    if self.selectedSubcategory == nil {
                        message = "There are no activities near you."
                        self.nearbyActivities = nil
                        self.tableView.reloadData()
                    }
                    else {
                        message = "There is no one interested in \(self.selectedSubcategory!) near you."
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
                if error != nil && error!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                        PFUser.logOut()
                        NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
                    })
                    return
                }
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
        
        self.performSegueWithIdentifier("GoToActivityBrowser", sender: activity)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "embedCategoriesVCSegue" {
            self.categoriesVC = segue.destinationViewController as! SearchCategoriesViewController
            self.categoriesVC.delegate = self
        }
        else if segue.identifier == "GoToActivityBrowser" {
            let controller: ActivityBrowserViewController = segue.destinationViewController as! ActivityBrowserViewController
            let activity = sender as! PFObject
            controller.currentActivity = activity
            controller.isRequestingJoin = true

            if self.selectedSubcategory == nil {
                controller.activities = self.nearbyActivities
            }
            else {
                controller.activities = self.filteredActivities
            }

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
    
    // MARK: InvitationDelegate side effects
    func updateActivities() {
        // after user sends an invitation, that activity should be removed from here
        self.didSelectCategory(self.selectedSubcategory, category: nil)
    }
}
