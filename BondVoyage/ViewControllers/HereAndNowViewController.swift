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
let kNearbyEventCellIdentifier = "nearbyEventCell"

class NearbyEventCell: UITableViewCell {
    @IBOutlet weak var viewImage: AsyncImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCellForNearbyEvent(recommendation: PFObject) {
        // TODO: set the image
        // TODO: set the label with activity name
        
        if let url: String = recommendation.objectForKey("imageURL") as? String {
            self.viewImage.imageURL = NSURL(string: url)
        }
        else if let image: PFFile = recommendation.objectForKey("image") as? PFFile {
            self.viewImage.imageURL = NSURL(string: image.url!)
        }
        
        if let title: String = recommendation.objectForKey("name") as? String {
            self.labelTitle.text = title
        }
        if let description: String = recommendation.objectForKey("description") as? String {
            self.labelInfo.text = description
        }
    }
}

class HereAndNowViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, SearchResultsDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
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
        
        if PFUser.currentUser() != nil && !self.appDelegate().hasPushEnabled() && !self.promptedForPush {
            self.appDelegate().registerForRemoteNotifications()
            self.promptedForPush = true
        }
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

    // MARK: - UITableViewDataSource

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kNearbyEventCellIdentifier)! as! NearbyEventCell
        cell.adjustTableViewCellSeparatorInsets(cell)
        
        let recommendation: PFObject = self.recommendations![indexPath.row]
        cell.configureCellForNearbyEvent(recommendation)
        cell.layoutSubviews()
        
        return cell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.recommendations == nil {
            return 0
        }
        return self.recommendations!.count
    }
    
    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

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

    func showUserDetails() {
        self.performSegueWithIdentifier("showUserDetailsSegue", sender: self)
    }
    
    
    
}
