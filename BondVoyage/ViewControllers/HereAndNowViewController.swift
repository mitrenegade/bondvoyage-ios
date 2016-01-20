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

let kSearchResultsViewControllerID = "searchResultsViewControllerID"

class HereAndNowViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, SearchResultsDelegate {

    // search dropdown
    @IBOutlet weak var constraintCategoriesHeight: NSLayoutConstraint!
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    var interests: [String]?
    var searchResultsVC: SearchResultsViewController!
    var searchResultsShowing: Bool!
    var selectedUser: PFUser?
    var recommendations: [PFObject]?
    
    var promptedForPush: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // configure search bar
        self.searchBar.delegate = self;

        self.searchResultsShowing = false
        
        let keyboardDoneButtonView: UIToolbar = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        keyboardDoneButtonView.barStyle = UIBarStyle.Black
        keyboardDoneButtonView.tintColor = UIColor.whiteColor()
        let close: UIBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: "dismissKeyboard")
        let search: UIBarButtonItem = UIBarButtonItem(title: "Search", style: UIBarButtonItemStyle.Done, target: self, action: "search")
        let flex: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        keyboardDoneButtonView.setItems([close, flex, search], animated: true)
        self.searchBar.inputAccessoryView = keyboardDoneButtonView
        
        RecommendationRequest.recommendationsQuery(nil, interests: [], completion: { (results, error) -> Void in
            self.recommendations = results
            self.tableView.reloadData()
        })
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if PFUser.currentUser() == nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log In", style: .Done, target: self, action: "goToLogin")
        }
        else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .Done, target: self, action: "goToSettings")
        }
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
        if !self.searchResultsShowing {
            self.searchBar.showsCancelButton = true
            self.containerView.alpha = 0
            self.view.bringSubviewToFront(self.containerView)
            UIView.animateWithDuration(0.15,
                animations: { () -> Void in
                    self.containerView.alpha = 1
                },
                completion: { (Bool) -> Void in
                    self.searchResultsShowing = true
                }
            )
        }
    }

    func removeSearchResultsViewController() {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        UIView.animateWithDuration(0.18,
            animations: { () -> Void in
                self.containerView.alpha = 0
            },
            completion: { (Bool) -> Void in
                self.view.bringSubviewToFront(self.tableView)
                self.searchResultsShowing = false
            }
        )
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "embedSearchResultsVCSegue" {
            self.searchResultsVC = segue.destinationViewController as! SearchResultsViewController
            self.searchResultsVC.delegate = self
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
            let genderPrefs: [String] = self.searchResultsVC.genderPrefs()
            let agePrefs: [Int] = self.searchResultsVC.agePrefs()
            UserRequest.userQuery(self.interests!, genderPref: genderPrefs, ageRange: agePrefs, numRange: [], completion: { (results, error) -> Void in
                if error != nil {
                    print("ERROR: \(error)")
                }
                else {
                    self.searchResultsVC.users = results
                    self.searchResultsVC.tableView.reloadData()
                }
            });
        }
    }

    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        self.displaySearchResultsViewController()
    }

    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.removeSearchResultsViewController()
        self.searchBar.resignFirstResponder()
    }

    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        //self.removeSearchResultsViewController()
        self.searchBar.resignFirstResponder()
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

    // MARK: SearchResultsDelegate

    func showUserDetails(user:PFUser?) {
        self.selectedUser = user
        self.performSegueWithIdentifier("showUserDetailsSegue", sender: self)
    }
    
    
    
}
