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

class RequestedBondsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserDetailsDelegate {
    let kCellIdentifier = "UserCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelNoBonds: UILabel!

    var activities: [PFObject] = []
    var tabIndex: BVTabIndex!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabIndex = .TAB_REQUESTED_BONDS

        // configure title bar
        let imageView: UIImageView = UIImageView(image: UIImage(named: "logo-plain")!)
        imageView.frame = CGRectMake(0, 0, 150, 44)
        imageView.contentMode = .ScaleAspectFit
        imageView.backgroundColor = Constants.lightBlueColor()
        imageView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, 22)
        self.navigationController!.navigationBar.addSubview(imageView)
        self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()
        
        self.refresh()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(RequestedBondsViewController.refreshNotifications), name: "activity:updated", object: nil)
        
        self.setLeftProfileButton()
        let button: UIButton = UIButton(frame: CGRectMake(0, 0, 30, 30))
        let image = UIImage(named: "icon-refresh")!.imageWithRenderingMode(.AlwaysTemplate)
        button.setImage(image, forState: .Normal)
        button.addTarget(self, action: #selector(RequestedBondsViewController.refresh), forControlEvents: .TouchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: "setup")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        HUD.show(.SystemActivity)
        self.setupWithCompletion {
            // used to be: update badge counts
            HUD.hide(animated: true, completion: { (success) -> Void in
            })
        }
    }
    
    func refreshNotifications() {
        self.setupWithCompletion(nil)
    }
    
    func setupWithCompletion( completion: (()->Void)? ) {
        activities.removeAll()
        self.navigationItem.rightBarButtonItem?.enabled = false
        self.labelNoBonds.hidden = true
        ActivityRequest.getRequestedBonds { (results, error) in
            self.navigationItem.rightBarButtonItem?.enabled = true
            // returns activities where the owner of the activity is the user, and someone is requesting a join
            if results != nil {
                self.activities.appendContentsOf(results!)
                if self.activities.count == 0 {
                    self.labelNoBonds.text = "There are currently no bond requests for you."
                    self.labelNoBonds.hidden = false
                }
                self.tableView.reloadData()
                if completion != nil {
                    completion!()
                }
            }
            else if error != nil {
                if error!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                        UserService.logout()
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
        
        // mark activity as seen
        var key: String
        if self.tabIndex == .TAB_REQUESTED_BONDS {
            key = "requestedBond:seen:"
        }
        else {
            key = "matchedBond:seen:"
        }
        let id = activity.objectId!
        key = "\(key)\(id)"
        NSUserDefaults.standardUserDefaults().setObject(true, forKey: key)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName("activity:updated", object: nil)
    }

    func goToActivity(activity: PFObject) {
        // join requests exist
        HUD.show(.SystemActivity)
        activity.getMatchedUser { (user) in
            self.tableView.userInteractionEnabled = true
            HUD.hide(animated: false)
            if user != nil {
                let controller: UserDetailsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("UserDetailsViewController") as! UserDetailsViewController
                controller.invitingUser = user
                controller.invitingActivity = activity
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else {
                self.tableView.userInteractionEnabled = true
            }
        }
    }
    
    // MARK: - UserDetailsDelegate
    func didRespondToInvitation() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
