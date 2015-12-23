//
//  HereAndNowViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/23/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit

class HereAndNowViewController: UIViewController, UISearchBarDelegate {

    let kSearchResultsViewControllerID = "searchResultsViewControllerID"

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var hereAndNowActivitiesView: UIView!
    var searchResultsVC: UIViewController!
    var searchResultsShowing: Bool! {
        get {
            return self.searchResultsVC.view.isDescendantOfView(self.hereAndNowActivitiesView)
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


    func displaySearchResultsViewController() {
        if !self.searchResultsShowing {
            self.searchBar.showsCancelButton = true
            self.searchResultsVC.view.alpha = 0
            self.hereAndNowActivitiesView.addSubview(self.searchResultsVC.view)
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
