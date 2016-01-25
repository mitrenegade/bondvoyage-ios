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

enum CATEGORY: String {
    case Arts = "Arts and Culture"
    case Business, Community, Education, Entertainment
    case Food = "Food and Drink"
    case Health = "Health and Fitness"
    case Music
    case Outdoors = "Outdoors and Adventure"
    case Sports = "Sports and Recreation"
    case Technology, Other
}

enum SUBCATEGORY: String {
    // arts
    case Museums
    case Gallery = "Art gallery"
    // business
    case Networking
    // community
    case Volunteering
    // education
    case Tutoring
    // entertainment
    case Movies
    case Theatre
    case Bowling
    // food
    case Brunch
    case Dinner
    case Drinks
    case BBQ
    // health
    case Yoga
    case Workout
    case Jogging
    case Gym
    // music
    case Concert
    case Jam = "Jam session"
    case Live = "Live music"
    case Opera
    // outdoors
    case Hiking
    case Volleyball
    case Beach
    // sports
    case Pickup = "Pickup sports"
    case WatchGame = "Watch the game"
    case SportsMatch = "Go to a match"
    // Technology
    case VideoGames = "Play video games"
    case LaserTag = "Laser tag"
}

var categories: [CATEGORY] = [.Arts, .Business, .Community, .Education, .Entertainment, .Food, .Health, .Music, .Outdoors, .Sports, .Technology]
var subcategories: [CATEGORY: [SUBCATEGORY]] = [
    .Arts: [.Museums, .Gallery],
    .Business: [.Networking],
    .Community: [.Volunteering],
    .Education: [.Tutoring],
    .Entertainment: [.Movies, .Theatre, .Bowling],
    .Food: [.Brunch, .Dinner, .Drinks, .BBQ],
    .Health: [.Yoga, .Workout, .Jogging, .Gym],
    .Music: [.Concert, .Jam, .Live, .Opera],
    .Outdoors: [.Hiking, .Volleyball, .Beach],
    .Sports: [.Pickup, .WatchGame, .SportsMatch],
    .Technology: [.VideoGames, .LaserTag]
]

class SearchCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var expanded: [Bool] = [Bool]()
    var selectedCategory: String?
    var matches: [PFObject]?
    var requestedMatch: PFObject?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for _ in subcategories.keys {
            expanded.append(false)
        }

        if PFUser.currentUser() == nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log In", style: .Done, target: self, action: "goToLogin")
        }
        else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .Done, target: self, action: "goToSettings")
        }
        
        self.checkForExistingMatch()

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
    
    // MARK: - API
    func checkForExistingMatch() {
        if PFUser.currentUser() == nil {
            return
        }
        
        let query: PFQuery = PFQuery(className: "Match")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.whereKey("status", notEqualTo: "cancelled")
        query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
            if results != nil && results!.count > 0 {
                self.requestedMatch = results![0]
                let categories = self.requestedMatch!.objectForKey("categories") as! [String]
                self.selectedCategory = categories[0]
                self.goToMatchStatus()
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell")!
            cell.textLabel!.text = categories[indexPath.section].rawValue
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SubcategoryCell")!
        let category = categories[indexPath.section]
        let subs = subcategories[category]
        let index = indexPath.row - 1
        cell.backgroundColor = UIColor.whiteColor()
        cell.textLabel!.text = subs![index].rawValue
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.expanded[section] {
            let category: CATEGORY = categories[section]
            if subcategories[category] != nil {
                return subcategories[category]!.count + 1
            }
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
            let category: CATEGORY = categories[indexPath.section]
            let subs: [SUBCATEGORY] = subcategories[category]!
            let index = indexPath.row - 1
            let subcategory: SUBCATEGORY = subs[index]
            self.goToCategoryQuery(subcategory.rawValue)
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
    
    func goToCreateMatch() {
        self.createMatch()
    }
    
    func goToInvite() {
        self.performSegueWithIdentifier("GoToInvite", sender: self)
    }
    
    func goToMatchStatus() {
        self.performSegueWithIdentifier("GoToMatchStatus", sender: self)
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GoToInvite" {
            let controller: InviteViewController = segue.destinationViewController as! InviteViewController
            controller.category = self.selectedCategory
            controller.matches = self.matches
            controller.fromMatch = self.requestedMatch
        }
        else if segue.identifier == "GoToMatchStatus" {
            let controller: MatchStatusViewController = segue.destinationViewController as! MatchStatusViewController
            controller.category = self.selectedCategory
            controller.fromMatch = self.requestedMatch
            controller.toMatch = nil
        }
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
                self.goToCreateMatch()
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
                self.requestedMatch = match
                
                if self.matches != nil {
                    self.goToInvite()
                }
                else {
                    self.goToMatchStatus()
                }
            }
            else {
                let message = "There was a problem setting up your activity. Please try again."
                self.simpleAlert("Could not initiate bond", defaultMessage: message, error: error)
            }
        }
    }

}
