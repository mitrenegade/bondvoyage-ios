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

class HereAndNowViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SearchCategoriesDelegate {

    // categories dropdown
    @IBOutlet weak var constraintCategoriesHeight: NSLayoutConstraint!
    var categoriesVC: SearchCategoriesViewController!
    
    // search results
    @IBOutlet weak var searchBar: UISearchBar!
    var interests: [String]?
    @IBOutlet weak var tableView: UITableView!
    var selectedUser: PFUser?
    var recommendations: [PFObject]?
    
    var promptedForPush: Bool = false
    var nearbyMatches: [PFObject]?
    
    // from SearchCategoriesDelegate
    var requestedMatch: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure search bar
        self.searchBar.delegate = self;
        for view: UIView in self.searchBar.subviews[0].subviews {
            if view.isKindOfClass(UITextField.self) {
                let textfield: UITextField = view as! UITextField
                textfield.inputView = UIView()
            }
        }
        
        self.constraintCategoriesHeight.constant = 0
        self.loadActivitiesForCategory(nil) { (results, error) -> Void in
            if results != nil && results!.count > 0 {
                self.nearbyMatches = results
            }
            self.tableView.reloadData()
        }

        self.checkForExistingMatch()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if PFUser.currentUser() == nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log In", style: .Done, target: self, action: "goToLogin")
        }
        else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .Done, target: self, action: "goToSettings")
        }

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
        query.whereKey("user", notEqualTo: PFUser.currentUser()!)
        query.whereKey("status", notContainedIn: ["cancelled", "declined"])
        if category != nil {
            query.whereKey("categories", containsString: category!)
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
        if nearbyMatches != nil {
            cell.configureCellForUser(self.nearbyMatches![indexPath.row])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numUsers: Int = self.nearbyMatches?.count {
            return numUsers
        }
        else {
            print("No matches found")
            return 0
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if PFUser.currentUser() == nil {
            self.simpleAlert("Log in?", message: "Log in or create an account to view someone's profile")
            return
        }
        
        self.requestedMatch = self.nearbyMatches![indexPath.row]
        self.performSegueWithIdentifier("GoToInvite", sender: [self.requestedMatch!])
    }
    
    // MARK: - Search Bar
    func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    func search() {
        self.searchBarSearchButtonClicked(self.searchBar)
    }
    
    func displaySearchResultsViewController() {
        self.searchBar.showsCancelButton = true
        self.constraintCategoriesHeight.constant = self.view.frame.size.height / 2
    }

    func removeSearchResultsViewController() {
        self.searchBar.resignFirstResponder()
        self.constraintCategoriesHeight.constant = 0
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
    }

    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchText: String = searchBar.text! {
            self.searchBar.resignFirstResponder()
            self.interests = searchText.componentsSeparatedByString(" ")
            if self.interests != nil {
                self.interests = self.interests!.map { (i) -> String in
                    return i.lowercaseString
                }
            }
            
            print("search")
        }
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.displaySearchResultsViewController()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.removeSearchResultsViewController()
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        self.removeSearchResultsViewController()
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            self.displaySearchResultsViewController()
            // TODO: search with searchText
        }
    }

    // MARK: Navigation
    func goToLogin() {
        let nav: UINavigationController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SignupNavigationController") as! UINavigationController
        let controller: SignUpViewController = nav.viewControllers[0] as! SignUpViewController
        controller.type = .Login
        self.presentViewController(nav, animated: true, completion: nil)
    }
    
    func goToSettings() {
        let nav: UINavigationController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SettingsNavigationController") as! UINavigationController
        self.presentViewController(nav, animated: true, completion: nil)
    }

    // MARK: - SearchCategoriesDelegate
    func goToMatchStatus(match: PFObject) {
        self.removeSearchResultsViewController()
        self.requestedMatch = match
        self.performSegueWithIdentifier("GoToMatchStatus", sender: self)
    }
    
    func goToInvite(match: PFObject, matches: [PFObject]) {
        self.removeSearchResultsViewController()
        self.requestedMatch = match
        self.performSegueWithIdentifier("GoToInvite", sender: matches)
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
    


}
