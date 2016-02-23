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

class HereAndNowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SearchCategoriesDelegate, SignupDelegate, CLLocationManagerDelegate {

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
    var nearbyMatches: [PFObject]?
    var filteredMatches: [PFObject]?
    var clickedAddButton: Bool = false
    
    // from SearchCategoriesDelegate
    var requestedMatch: PFObject?
    
    var promptedForPush: Bool = false
    
    // location
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?

    var placePicker: GMSPlacePicker?

    // button
    @IBOutlet weak var buttonAdd: UIButton!
    
    weak var delegate: SettingsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure title bar
        let imageView: UIImageView = UIImageView(image: UIImage(named: "logo-plain")!)
        imageView.frame = CGRectMake(0, 0, 150, 44)
        imageView.contentMode = .ScaleAspectFit
        imageView.backgroundColor = Constants.lightBlueColor()
        imageView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, 22)
        //self.navigationItem.titleView = imageView
        self.navigationController!.navigationBar.addSubview(imageView)
        self.constraintCategoriesHeight.constant = 0
        self.didSelectCategory(nil)

        self.checkForExistingMatch()
        
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .Plain, target: self, action: "goToSettings")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .Plain, target: self, action: "didClickButton:")
        self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()
        
        self.constraintCategoriesHeight.constant = 0
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

    // MARK: - API
    func checkForExistingMatch() {
        if PFUser.currentUser() == nil {
            return
        }
        
        let query: PFQuery = PFQuery(className: "Match")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.whereKey("status", notContainedIn: ["cancelled", "declined"])
        query.orderByDescending("updatedAt")
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if results != nil && results!.count > 0 {
                print("existing matches: \(results!)")
                self.requestedMatch = results![0]
                self.goToMatchStatus(self.requestedMatch!)
            }
        }
    }
    
    func loadActivitiesForCategory(category: String?, completion: ((results: [PFObject]?, error: NSError?)->Void)) {
        var cat: [String]?
        if category != nil {
            cat = [category!]
        }
        MatchRequest.queryMatches(self.currentLocation, categories: cat) { (results, error) -> Void in
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
        if self.selectedCategory == nil && nearbyMatches != nil {
            cell.configureCellForUser(self.nearbyMatches![indexPath.row])
        }
        else if self.selectedCategory != nil && filteredMatches != nil {
            cell.configureCellForUser(self.filteredMatches![indexPath.row])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows = 0
        if self.selectedCategory != nil {
            if let count: Int = self.filteredMatches?.count {
                rows = count
            }
            else {
                rows = 0
            }
        }
        else {
            if let count: Int = self.nearbyMatches?.count {
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
        
        if self.selectedCategory != nil {
            // show all the users in the category
            self.goToInvite(self.filteredMatches!, index: indexPath.row)
        }
        else {
            // only show the one user that was clicked
            let match: PFObject = self.nearbyMatches![indexPath.row]
            self.goToUser(match)
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
            self.clickedAddButton = false
            self.didSelectCategory(nil)
        }
    }
    
    func hideCategories() {
        self.showingCategories = false
        self.constraintCategoriesHeight.constant = 0
        // don't animate or tableview looks weird
    }

    // MARK: Navigation
    func goToSettings() {
        let nav: UINavigationController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SettingsNavigationController") as! UINavigationController
        let controller: SettingsViewController = nav.viewControllers[0] as! SettingsViewController
        controller.delegate = self.delegate
        self.presentViewController(nav, animated: true, completion: nil)
    }

    // MARK: - SearchCategoriesDelegate
    func didSelectCategory(category: String?) {
        if self.clickedAddButton {
            self.clickedAddButton = false
            self.createMatch(category!, completion: { (result, error) -> Void in
                self.toggleCategories(false)
                if result != nil {
                    let match: PFObject = result!
                    self.goToMatchStatus(match)
                    self.view.endEditing(true)
                }
                else {
                    self.simpleAlert("Could not create activity", defaultMessage: "We could not create an activity for \(category!)", error: error)
                }
            })
            return
        }
        // first query for existing bond requests
        self.selectedCategory = category
        self.loadActivitiesForCategory(category?.lowercaseString) { (results, error) -> Void in
            if results != nil {
                if results!.count > 0 {
                    
                    if self.selectedCategory == nil {
                        self.nearbyMatches = results
                    }
                    else {
                        self.filteredMatches = results
                    }
                    self.tableView.reloadData()
                    self.hideCategories()
                }
                else {
                    // no results, no error
                    var message = ""
                    if self.selectedCategory == nil {
                        message = "There are no activities near you."
                        self.nearbyMatches = nil
                        self.tableView.reloadData()
                    }
                    else {
                        message = "There is no one interested in \(self.selectedCategory!) near you."
                        self.filteredMatches = nil
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
    
    func createMatch(category: String, completion: ((result: PFObject?, error: NSError?)->Void)) {
        if PFUser.currentUser() == nil {
            completion(result: nil, error: nil)
            return
        }
        if self.currentLocation == nil {
            self.warnForLocationAvailability()
            completion(result: nil, error: nil)
            return
        }
        // no existing requests exist. Create a request for others to match to
        let categories: [String] = [category]
        MatchRequest.createMatch(categories, location: self.currentLocation!) { (result, error) -> Void in
            self.requestedMatch = result
            completion(result: result, error: error)
        }
    }
    
    func goToMatchStatus(match: PFObject) {
        self.hideCategories()
        self.requestedMatch = match
        self.performSegueWithIdentifier("GoToMatchStatus", sender: self)
    }
    
    func goToUser(match: PFObject) {
        if self.currentLocation == nil || self.currentLocation!.horizontalAccuracy >= 100 {
            if TESTING {
                self.currentLocation = CLLocation(latitude: PHILADELPHIA_LAT, longitude: PHILADELPHIA_LON)
            }
            else {
                self.warnForLocationAvailability()
                return
            }
        }

        if let categories: [String] = match.objectForKey("categories") as? [String] {
            let category = categories[0]
            self.createMatch(category, completion: { (result, error) -> Void in
                if result != nil {
                    self.performSegueWithIdentifier("GoToInvite", sender: [match])
                }
                else {
                    self.selectedCategory = nil
                    let message = "There was a problem setting up your activity. Please try again."
                    self.simpleAlert("Could not initiate bond", defaultMessage: message, error: error)
                }
            })
        }
    }
    
    func goToInvite(matches: [PFObject], index: Int) {
        if self.currentLocation == nil || self.currentLocation!.horizontalAccuracy >= 100 {
            self.warnForLocationAvailability()
            return
        }
        
        self.hideCategories()
        self.createMatch(self.selectedCategory!, completion: { (result, error) -> Void in
            if result != nil {
                let match: PFObject = matches[index]
                var mutable: [PFObject] = matches
                mutable.removeAtIndex(index)
                mutable.insert(match, atIndex: 0)
                self.performSegueWithIdentifier("GoToInvite", sender: mutable)
            }
            else {
                let message = "There was a problem setting up your activity. Please try again."
                self.simpleAlert("Could not initiate bond", defaultMessage: message, error: error)
            }
        })
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "embedCategoriesVCSegue" {
            self.categoriesVC = segue.destinationViewController as! SearchCategoriesViewController
            self.categoriesVC.delegate = self
        }
        else if segue.identifier == "GoToInvite" {
            let controller: InviteViewController = segue.destinationViewController as! InviteViewController
            let matches: [PFObject] = sender as! [PFObject]
            controller.matches = matches
            controller.fromMatch = self.requestedMatch
        }
        else if segue.identifier == "GoToMatchStatus" {
            let controller: MatchStatusViewController = segue.destinationViewController as! MatchStatusViewController
            controller.requestedMatch = self.requestedMatch
            controller.fromMatch = nil
            controller.toMatch = nil
        }
    }
    
    // MARK: SignupDelegate
    func didLogin() {
        // no longer used
        self.didSelectCategory(nil)
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
        if sender == self.buttonAdd {
            if self.showingCategories && self.clickedAddButton {
                self.toggleCategories(false)
            }
            else {
                self.clickedAddButton = true
                self.toggleCategories(true)
            }
        }
        else if sender == self.navigationItem.rightBarButtonItem {
            self.toggleCategories(!self.showingCategories)
        }
    }
}
