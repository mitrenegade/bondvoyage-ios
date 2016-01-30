//
//  SearchCategoriesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import AsyncImageView
import Parse

let kNearbyEventCellIdentifier = "nearbyEventCell"

protocol SearchCategoriesDelegate: class {
    func goToInvite(match: PFObject, matches: [PFObject])
    func goToMatchStatus(match: PFObject)
}
class SearchCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var expanded: [Bool] = [Bool]()
    
    var selectedCategory: String?
    var matches: [PFObject]?

    weak var delegate: SearchCategoriesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for _ in CategoryFactory.categories() {
            expanded.append(false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell")!
            cell.textLabel!.text = CategoryFactory.categories()[indexPath.section]
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SubcategoryCell")!
        let category = CategoryFactory.categories()[indexPath.section]
        let subs = CategoryFactory.subCategories(category)
        let index = indexPath.row - 1
        cell.backgroundColor = UIColor.whiteColor()
        cell.textLabel!.text = subs[index]
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return CategoryFactory.categories().count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.expanded[section] {
            let category: String = CategoryFactory.categories()[section]
            return CategoryFactory.subCategories(category).count + 1
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            expanded[indexPath.section] = !expanded[indexPath.section]
            self.tableView.reloadData()
        }
        else {
            let category = CategoryFactory.categories()[indexPath.section]
            let subs = CategoryFactory.subCategories(category)
            let index = indexPath.row - 1
            let subcategory: String = subs[index]
            self.goToCategoryQuery(subcategory)
        }
    }
    
    func goToCategoryQuery(category: String) {
        // first query for existing bond requests
        if PFUser.currentUser() == nil {
            self.simpleAlert("Log in to find matches", message: "Please log in or sign up to bond with someone", completion: nil)
            return
        }
        self.selectedCategory = category
        self.queryForMatches()
    }
    
    // MARK: - API
    // MARK: - API calls
    func queryForMatches() {
        // searches for existing requests for category. Does not create own request
        var categories: [String] = []
        if self.selectedCategory != nil {
            categories = [self.selectedCategory!]
        }
        MatchRequest.queryMatches(nil, categories: categories) { (results, error) -> Void in
            if results != nil {
                if results!.count > 0 {
                    self.matches = results
                }
                else {
                    self.matches = nil
                }
                self.createMatch()
            }
            else {
                let message = "There was a problem loading matches. Please try again"
                self.simpleAlert("Could not select category", defaultMessage: message, error: error)
            }
        }
    }
    
    func createMatch() {
        // no existing requests exist. Create a request for others to match to
        var categories: [String] = []
        if self.selectedCategory != nil {
            categories = [self.selectedCategory!]
        }
        MatchRequest.createMatch(categories) { (result, error) -> Void in
            if result != nil {
                let match: PFObject = result! as PFObject
                if self.matches != nil {
                    self.delegate?.goToInvite(match, matches: self.matches!)
                }
                else {
                    self.delegate?.goToMatchStatus(match)
                }
            }
            else {
                let message = "There was a problem setting up your activity. Please try again."
                self.simpleAlert("Could not initiate bond", defaultMessage: message, error: error)
            }
        }
    }

}
