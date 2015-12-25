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

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var searchResultsVC: UIViewController!
    var searchResultsShowing: Bool! {
        get {
            return self.searchResultsVC.view.isDescendantOfView(self.view)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // configure search bar
        self.searchBar.delegate = self;

        // configure search results view controller
        self.searchResultsVC = storyboard?.instantiateViewControllerWithIdentifier(kSearchResultsViewControllerID)
        self.addChildViewController(self.searchResultsVC)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = true
    }

    func displaySearchResultsViewController() {
        if !self.searchResultsShowing {
            self.searchBar.showsCancelButton = true
            self.searchResultsVC.view.alpha = 0
            self.searchResultsVC.view.frame = self.tableView.frame
            self.view.addSubview(self.searchResultsVC.view)
            UIView.animateWithDuration(0.25) { () -> Void in
                self.searchResultsVC.view.alpha = 1
            }
        }
    }

    func removeSearchResultsViewController() {
        self.searchBar.showsCancelButton = false
        self.searchBar.text = ""
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.searchResultsVC.view.alpha = 0
            }) { (Bool) -> Void in
                self.searchResultsVC.view.removeFromSuperview()
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
        return 5 // TODO: return count of nearby events
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

    // MARK: - UISearchBarDelegate

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
