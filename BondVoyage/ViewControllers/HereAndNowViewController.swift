//
//  HereAndNowViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/23/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit
import Parse

let kSearchResultsViewControllerID = "searchResultsViewControllerID"
let kNearbyEventCellIdentifier = "nearbyEventCell"

class NearbyEventCell: UITableViewCell {

    func configureCellForNearbyEvent() {
        // TODO: set the image
        // TODO: set the label with activity name
    }
}

class HereAndNowViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var searchResultsVC: SearchResultsViewController!
    var searchResultsShowing: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()

        // configure search bar
        self.searchBar.delegate = self;

        self.searchResultsShowing = false
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .Done, target: self, action: "goToSettings")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //self.navigationController?.navigationBarHidden = true
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
        if (segue.identifier == "embedSearchResultsVCSegue") {
            self.searchResultsVC = segue.destinationViewController as! SearchResultsViewController
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier(kNearbyEventCellIdentifier)!
        cell.adjustTableViewCellSeparatorInsets(cell)
        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5 //TODO: return actual number of nearby Events
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

    // MARK: - UISearchBarDelegate

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let searchText: String = searchBar.text! {
            let keywords = searchText.componentsSeparatedByString(" ")
            UserRequest.userQuery(keywords, completion: { (results, error) -> Void in
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
        self.removeSearchResultsViewController()
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count > 0 {
            self.displaySearchResultsViewController()
            // TODO: search with searchText
        }
    }

    func goToSettings() {
        // go to signup view
        if PFUser.currentUser() == nil {
            let nav: UINavigationController = UIStoryboard(name: "Log in", bundle: nil).instantiateViewControllerWithIdentifier("SignupNavigationController") as! UINavigationController
            let controller: SignUpViewController = nav.viewControllers[0] as! SignUpViewController
            controller.type = .Login
            self.presentViewController(nav, animated: true, completion: nil)
        }
        else {
            let nav: UINavigationController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SettingsNavigationController") as! UINavigationController
            self.presentViewController(nav, animated: true, completion: nil)
        }
    }
}
