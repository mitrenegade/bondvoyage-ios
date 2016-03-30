//
//  MyActivitiesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/24/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class RequestedBondsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UserDetailsDelegate {
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
        
        self.setup()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setup", name: "activity:updated", object: nil)
        
        self.setLeftProfileButton()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: "setup")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        activities.removeAll()
        self.navigationItem.rightBarButtonItem?.enabled = false
        ActivityRequest.queryActivities(PFUser.currentUser(), joining: false, categories: nil, location: nil, distance: nil, aboutSelf: nil, aboutOthers: []) { (results, error) -> Void in
            self.navigationItem.rightBarButtonItem?.enabled = true
            // returns activities where the owner of the activity is the user, and someone is requesting a join
            if results != nil {
                if results!.count > 0 {
                    for activity: PFObject in results! {
                        if activity.isAcceptedActivity() {
                            // skip matched activities
                            continue
                        }
                        if let joining: [String] = activity.objectForKey("joining") as? [String] {
                            if joining.count > 0 {
                                self.activities.append(activity)
                            }
                        }
                    }
                }
                else {
                    self.simpleAlert("No requested bonds", message: "There are currently no bond requests for you.")
                }
                self.tableView.reloadData()
            }
            if error != nil {
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
        self.goToAcceptInvitation(activity)
    }

    func goToAcceptInvitation(activity: PFObject) {
        // join requests exist
        if let userIds: [String] = activity.objectForKey("joining") as? [String] {
            let userId = userIds[0]
            let query: PFQuery = PFUser.query()!
            query.whereKey("objectId", equalTo: userId)
            query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                if results != nil && results!.count > 0 {
                    let user: PFUser = results![0] as! PFUser
                    let controller: UserDetailsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("UserDetailsViewController") as! UserDetailsViewController
                    controller.invitingUser = user
                    controller.invitingActivity = activity
                    controller.delegate = self
                    self.navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    
    // MARK: - UserDetailsDelegate
    func didRespondToInvitation() {
        print("declined")
        self.setup()
        self.navigationController!.popToViewController(self, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToActivityDetail" {
            let controller: ActivityDetailViewController = segue.destinationViewController as! ActivityDetailViewController
            controller.activity = sender as! PFObject
            controller.isRequestingJoin = false
        }
    }
}
