//
//  HereAndNowViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/23/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit

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
    var searchResultsShowing: Bool! {
        get {
            return self.searchResultsVC.view.isDescendantOfView(self.view)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // configure search bar
        self.searchBar.delegate = self;

        self.searchResultsVC = storyboard?.instantiateViewControllerWithIdentifier(kSearchResultsViewControllerID) as? SearchResultsViewController
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }

    func displaySearchResultsViewController() {
        if !self.searchResultsShowing {
            self.searchBar.showsCancelButton = true
            self.searchResultsVC.view.alpha = 0
            self.view.bringSubviewToFront(self.containerView)
            UIView.animateWithDuration(10, animations: { () -> Void in
                self.searchResultsVC.view.alpha = 1
            })
        }
    }

    func removeSearchResultsViewController() {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        UIView.animateWithDuration(10, animations: { () -> Void in
            self.searchResultsVC.view.alpha = 0
            }) { (Bool) -> Void in
                self.view.bringSubviewToFront(self.tableView)
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
            //TODO: parse searchText
            UserRequest.userQuery([searchText], completion: { (results, error) -> Void in
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

}
