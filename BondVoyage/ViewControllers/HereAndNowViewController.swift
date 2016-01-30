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

let kSearchResultCellIdentifier = "searchResultCell"

class UserSearchResultCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: AsyncImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var genderAndAgeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    func configureCellForUser(user: PFUser) {
        let currentYear = components.year
        let age = currentYear - (user.valueForKey("birthYear") as! Int)
        
        var name: String? = user.valueForKey("firstName") as? String
        if name == nil {
            name = user.valueForKey("lastName") as? String
        }
        if name == nil {
            name = user.username
        }
        self.usernameLabel.text = name
        self.genderAndAgeLabel.text = "\(user.valueForKey("gender")!), age: \(age)"
        
        var info: String? = nil
        if let interests: [String] = user.valueForKey("interests") as? [String] {
            if interests.count > 0 {
                info = "Likes: \(interests[0])"
                if interests.count > 1 {
                    for var i=1; i < interests.count; i++ {
                        info = "\(info!), \(interests[i])"
                    }
                }
            }
        }
        self.infoLabel.text = info
        
        if let photoURL: String = user.valueForKey("photoUrl") as? String {
            self.profileImage.imageURL = NSURL(string: photoURL)
        }
        else {
            self.profileImage.image = UIImage(named: "profile-icon")
        }
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.layer.borderColor = Constants.blueColor().CGColor
        self.profileImage.layer.borderWidth = 2
    }
}

class HereAndNowViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

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
    var users: [PFUser]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // configure search bar
        self.searchBar.delegate = self;
        
        self.constraintCategoriesHeight.constant = 0
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedCategoriesVCSegue" {
            self.categoriesVC = segue.destinationViewController as! SearchCategoriesViewController
        }
        else if segue.identifier == "showUserDetailsSegue" {
            let userDetailsVC = segue.destinationViewController as! UserDetailsViewController
            userDetailsVC.selectedUser = self.selectedUser
            userDetailsVC.relevantInterests = self.interests
        }
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
            UserRequest.userQuery(self.interests!, genderPref: [], ageRange: [], numRange: [], completion: { (results, error) -> Void in
                if error != nil {
                    print("ERROR: \(error)")
                }
                else {
                    self.users = results
                    self.tableView.reloadData()
                }
            });
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

    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if PFUser.currentUser() == nil {
            self.simpleAlert("Log in?", message: "Log in or create an account to view someone's profile")
            return
        }
        
        let user = users![indexPath.row]
        self.selectedUser = user
        self.performSegueWithIdentifier("showUserDetailsSegue", sender: self)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kSearchResultCellIdentifier)! as! UserSearchResultCell
        cell.adjustTableViewCellSeparatorInsets(cell)
        if users != nil {
            cell.configureCellForUser(users![indexPath.row])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numUsers: Int = users?.count {
            return numUsers
        }
        else {
            print("No users found")
            return 0
        }
    }
    
}
