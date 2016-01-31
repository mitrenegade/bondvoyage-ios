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

let date = NSDate()
let calendar = NSCalendar.currentCalendar()
let components = calendar.components([.Day , .Month , .Year], fromDate: date)

let kCellIdentifier = "ActivitiesCell"

class HereAndNowViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SearchCategoriesDelegate, SignupDelegate {

    // categories dropdown
    @IBOutlet weak var constraintCategoriesHeight: NSLayoutConstraint!
    var categoriesVC: SearchCategoriesViewController!
    
    // search results
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var selectedUser: PFUser?
    var recommendations: [PFObject]?
    
    // tableview data
    var selectedCategory: String?
    var nearbyMatches: [PFObject]?
    var filteredMatches: [PFObject]?
    
    // from SearchCategoriesDelegate
    var requestedMatch: PFObject?
    
    var promptedForPush: Bool = false

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
        // configure search bar
        self.searchBar.delegate = self;
        for view: UIView in self.searchBar.subviews[0].subviews {
            if view.isKindOfClass(UITextField.self) {
                let textfield: UITextField = view as! UITextField
                textfield.inputView = UIView()
            }
        }
        
        self.constraintCategoriesHeight.constant = 0
        self.didSelectCategory(nil)

        self.checkForExistingMatch()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let button: UIButton = UIButton(type: .Custom)
        button.frame = CGRectMake(0, 0, 80, 30)
        button.backgroundColor = UIColor.clearColor()
        button.setBackgroundImage(UIImage(), forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        if PFUser.currentUser() == nil {
            button.addTarget(self, action: "goToLogin", forControlEvents: .TouchUpInside)
            button.setTitle("Log In", forState: .Normal)
        }
        else {
            button.addTarget(self, action: "goToSettings", forControlEvents: .TouchUpInside)
            button.setTitle("Settings", forState: .Normal)
        }

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
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
        let query: PFQuery = PFQuery(className: "Match")
        if PFUser.currentUser() != nil {
            query.whereKey("user", notEqualTo: PFUser.currentUser()!)
        }
        query.whereKey("status", notContainedIn: ["cancelled", "declined"])
        if category != nil {
            query.whereKey("categories", equalTo: category!)
        }
        query.orderByDescending("updatedAt")
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
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
            self.simpleAlert("Log in?", message: "Log in or create an account to view someone's profile")
            return
        }
        
        if self.selectedCategory != nil {
            // show all the users in the category
            self.goToInvite(self.filteredMatches!)
        }
        else {
            // only show the one user that was clicked
            self.goToInvite(self.nearbyMatches!)
        }
    }
    
    // MARK: - Search Bar
    func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    func displaySearchResultsViewController() {
        self.searchBar.showsCancelButton = true
        self.constraintCategoriesHeight.constant = self.view.frame.size.height / 2
    }

    func removeSearchResultsViewController() {
        self.dismissKeyboard()
        self.constraintCategoriesHeight.constant = 0
    }

    // MARK: - UISearchBarDelegate
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.displaySearchResultsViewController()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.removeSearchResultsViewController()
        self.didSelectCategory(nil)
        self.searchBar.text = nil
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.removeSearchResultsViewController()
        self.searchBar.showsCancelButton = false
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            self.displaySearchResultsViewController()
            // TODO: search with searchText
        }
        else {
            self.searchBar.resignFirstResponder() // required or searchBar will begin editing again
            self.searchBarTextDidEndEditing(searchBar)
        }
    }

    // MARK: Navigation
    func goToLogin() {
        let nav: UINavigationController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SignupNavigationController") as! UINavigationController
        let controller: SignUpViewController = nav.viewControllers[0] as! SignUpViewController
        controller.type = .Login
        controller.delegate = self
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func goToSettings() {
        let nav: UINavigationController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SettingsNavigationController") as! UINavigationController
        self.presentViewController(nav, animated: true, completion: nil)
    }

    // MARK: - SearchCategoriesDelegate
    func didSelectCategory(category: String?) {
        // first query for existing bond requests
        self.selectedCategory = category
        self.searchBar.text = category
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
                    self.removeSearchResultsViewController()
                }
                else {
                    // no results, no error
                    var message = ""
                    if self.selectedCategory == nil {
                        message = "There are no activities near you."
                        self.nearbyMatches = nil
                    }
                    else {
                        message = "There is no one interested in \(self.selectedCategory!) near you."
                        self.filteredMatches = nil
                    }
                    self.tableView.reloadData()
                    self.removeSearchResultsViewController()

                    if PFUser.currentUser() != nil {
                        message = "\(message) Would you like to create one?"
                    }
                    let alert: UIAlertController = UIAlertController(title: "No activities nearby", message: message, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                        self.selectedCategory = nil // if search result is nil due to a category, reload using existing nearbyMatches
                        self.tableView.reloadData()
                        self.searchBarCancelButtonClicked(self.searchBar)
                    }))
                    if PFUser.currentUser() != nil {
                        alert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action) -> Void in
                            self.createMatch({ (result, error) -> Void in
                                if result != nil {
                                    let match: PFObject = result! as PFObject
                                    self.goToMatchStatus(match)
                                }
                                else {
                                    let message = "There was a problem setting up your activity. Please try again."
                                    self.simpleAlert("Could not initiate bond", defaultMessage: message, error: error)
                                }
                            })
                        }))
                    }
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else {
                let message = "There was a problem loading matches. Please try again"
                self.simpleAlert("Could not select category", defaultMessage: message, error: error)
            }
        }
    }
    
    func createMatch(completion: ((result: PFObject?, error: NSError?)->Void)) {
        if PFUser.currentUser() == nil {
            completion(result: nil, error: nil)
            return
        }
        // no existing requests exist. Create a request for others to match to
        var categories: [String] = []
        if self.selectedCategory != nil {
            categories = [self.selectedCategory!]
        }
        MatchRequest.createMatch(categories) { (result, error) -> Void in
            completion(result: result, error: error)
        }
    }
    
    func goToMatchStatus(match: PFObject) {
        self.removeSearchResultsViewController()
        self.requestedMatch = match
        self.performSegueWithIdentifier("GoToMatchStatus", sender: self)
    }
    
    func goToInvite(matches: [PFObject]) {
        self.removeSearchResultsViewController()
        // FIXME: goToInvite just by clicking on a user should not create an invite
        // clicking back from inviteViewController should not cancel the fromMatch
        // createMatch should only be called if we click Invite to bond
        
        self.createMatch { (result, error) -> Void in
            if result != nil {
                self.requestedMatch = result! as PFObject
                self.performSegueWithIdentifier("GoToInvite", sender: matches)
            }
            else {
                let message = "There was a problem setting up your activity. Please try again."
                self.simpleAlert("Could not initiate bond", defaultMessage: message, error: error)
            }
        }
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
        self.didSelectCategory(nil)
    }

}
