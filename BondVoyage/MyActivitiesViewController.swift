//
//  MyActivitiesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/24/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class MyActivitiesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!

    var myActivities: [PFObject]?
    var myJoiningActivities: [PFObject]?

    override func viewDidLoad() {
        super.viewDidLoad()

        // configure title bar
        let imageView: UIImageView = UIImageView(image: UIImage(named: "logo-plain")!)
        imageView.frame = CGRectMake(0, 0, 150, 44)
        imageView.contentMode = .ScaleAspectFit
        imageView.backgroundColor = Constants.lightBlueColor()
        imageView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, 22)
        self.navigationController!.navigationBar.addSubview(imageView)
        
        self.setup()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setup", name: "activity:created", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setup", name: "invitation:sent", object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {
        ActivityRequest.queryActivities(nil, user: PFUser.currentUser(), joining: false, categories: nil) { (results, error) -> Void in
            if results != nil {
                if results!.count > 0 {
                    self.myActivities = results
                    self.tableView.reloadData()
                }
            }
        }
        ActivityRequest.queryActivities(nil, user: PFUser.currentUser(), joining: true, categories: nil) { (results, error) -> Void in
            if results != nil {
                if results!.count > 0 {
                    self.myJoiningActivities = results
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "My activities"
        }
        else {
            return "Activities I'm joining"
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier)! as! ActivitiesCell
        cell.adjustTableViewCellSeparatorInsets(cell)
        if indexPath.section == 0 && self.myActivities != nil {
            cell.configureCellForUser(self.myActivities![indexPath.row])
        }
        else if indexPath.section == 1 && self.myJoiningActivities != nil {
            cell.configureCellForUser(self.myJoiningActivities![indexPath.row])
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.myActivities == nil {
                return 0
            }
            return self.myActivities!.count
        }
        else {
            if self.myJoiningActivities == nil {
                return 0
            }
            return self.myJoiningActivities!.count
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if PFUser.currentUser() == nil {
            self.simpleAlert("Please log in", message: "Log in or create an account to view someone's profile")
            return
        }
        
        if indexPath.section == 0 {
            let activity: PFObject = self.myActivities![indexPath.row]
            self.goToActivity(activity)
        }
        else {
            let activity: PFObject = self.myJoiningActivities![indexPath.row]
            self.goToActivity(activity)
        }
    }

    func goToActivity(activity: PFObject) {
        self.performSegueWithIdentifier("GoToActivityDetail", sender: activity)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToActivityDetail" {
            let controller: ActivityDetailViewController = segue.destinationViewController as! ActivityDetailViewController
            controller.activity = sender as! PFObject
            controller.isRequestingJoin = false
        }
    }
}
