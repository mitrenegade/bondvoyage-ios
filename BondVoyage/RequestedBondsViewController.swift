//
//  MyActivitiesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/24/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse
import PKHUD

class RequestedBondsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let kCellIdentifier = "UserCell"
    
    @IBOutlet weak var tableView: UITableView!

    var activities: [PFObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // configure title bar
        let imageView: UIImageView = UIImageView(image: UIImage(named: "logo-plain")!)
        imageView.frame = CGRectMake(0, 0, 150, 44)
        imageView.contentMode = .ScaleAspectFit
        imageView.backgroundColor = Constants.lightBlueColor()
        imageView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, 22)
        self.navigationController!.navigationBar.addSubview(imageView)
        self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()
        
        self.refresh()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: "activity:updated", object: nil)
        
        self.setLeftProfileButton()
        let button: UIButton = UIButton(frame: CGRectMake(0, 0, 30, 30))
        let image = UIImage(named: "icon-refresh")!.imageWithRenderingMode(.AlwaysTemplate)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: "refresh", forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: "setup")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        self.setupWithCompletion { 
            self.refreshBadgeCount()
        }
    }
    
    func setupWithCompletion( completion: (()->Void)? ) {
        activities.removeAll()
        self.navigationItem.rightBarButtonItem?.enabled = false
        HUD.show(.SystemActivity)
        ActivityRequest.getRequestedBonds { (results, error) in
            self.navigationItem.rightBarButtonItem?.enabled = true
            // returns activities where the owner of the activity is the user, and someone is requesting a join
            HUD.hide(animated: true, completion: { (success) -> Void in
                if results != nil {
                    self.activities.appendContentsOf(results!)
                    if self.activities.count == 0 {
                        self.simpleAlert("No requested bonds", message: "There are currently no bond requests for you.")
                    }
                    self.tableView.reloadData()
                    if completion != nil {
                        completion!()
                    }
                }
                else if error != nil {
                    if error!.code == 209 {
                        self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                            PFUser.logOut()
                            NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
                        })
                        return
                    }
                    else {
                        self.simpleAlert("Could not load bonds", defaultMessage: "Please click refresh to try again.", error: error)
                    }
                    if completion != nil {
                        completion!()
                    }
                }
            })
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier)! as! UserCell
        cell.adjustTableViewCellSeparatorInsets(cell)
        let activity: PFObject = self.activities[indexPath.row]
        cell.configureCellForActivity(activity)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activities.count
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if PFUser.currentUser() == nil {
            self.simpleAlert("Please log in", message: "Log in or create an account to view someone's profile")
            return
        }
        
        let activity: PFObject = self.activities[indexPath.row]
        self.tableView.userInteractionEnabled = false
        self.goToActivity(activity)
    }

    func goToActivity(activity: PFObject) {
        // join requests exist
        if let userIds: [String] = activity.objectForKey("joining") as? [String] {
            let userId = userIds[0]
            let query: PFQuery = PFUser.query()!
            query.whereKey("objectId", equalTo: userId)
            query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                self.tableView.userInteractionEnabled = true
                if results != nil && results!.count > 0 {
                    let user: PFUser = results![0] as! PFUser
                    let controller: UserDetailsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("UserDetailsViewController") as! UserDetailsViewController
                    controller.invitingUser = user
                    controller.invitingActivity = activity
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
        else {
            self.tableView.userInteractionEnabled = true
        }
    }
    
    // MARK: - Badges
    func setBadgeCount() {
        // badges are all matches within the last hour that have not been stored into defaults as "seen"
        self.setupWithCompletion({
            self.refreshBadgeCount()
        })
    }
    
    func refreshBadgeCount() {
        var ct = 0
        for activity: PFObject in self.activities {
            let id = activity.objectId!
            let key = "requestedBond:seen:\(id)"
            if NSUserDefaults.standardUserDefaults().objectForKey(key) != nil && NSUserDefaults.standardUserDefaults().objectForKey(key) as! Bool == true {
                continue
            }
            let created = activity.objectForKey("time") as! NSDate
            if created.timeIntervalSinceNow <= -6000*60 {
                continue
            }
            ct = ct + 1
        }
        if ct > 0 {
            self.navigationController?.tabBarItem.badgeValue = "\(ct)"
        }
        else {
            self.navigationController?.tabBarItem.badgeValue = nil
        }
    }
}
