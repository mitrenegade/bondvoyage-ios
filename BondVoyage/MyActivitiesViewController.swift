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

    var myNewActivities: [PFObject] = [] // my activities with no invitations
    var myInvitedActivities: [PFObject] = [] // my activities with invitations
    var myJoiningActivities: [PFObject] = [] // activities i'm requesting to join
    var myAcceptedActivities: [PFObject] = []  // activies i've accepted or was accepted to join

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setup() {

        myNewActivities.removeAll()
        myInvitedActivities.removeAll()
        myJoiningActivities.removeAll()
        myAcceptedActivities.removeAll()
        
        ActivityRequest.queryActivities(nil, user: PFUser.currentUser(), joining: false, categories: nil) { (results, error) -> Void in
            // returns activities where the owner of the activity is the user
            if results != nil {
                if results!.count > 0 {
                    for activity: PFObject in results! {
                        if activity.isAcceptedActivity() {
                            self.myAcceptedActivities.append(activity)
                            continue
                        }
                        if let joining: [String] = activity.objectForKey("joining") as? [String] {
                            if joining.count > 0 {
                                self.myInvitedActivities.append(activity)
                                continue
                            }
                        }
                        self.myNewActivities.append(activity)
                    }
                    self.tableView.reloadData()
                }
            }
        }
        ActivityRequest.queryActivities(nil, user: PFUser.currentUser(), joining: true, categories: nil) { (results, error) -> Void in
            // returns activities where the owner is not the user but is in the joining list
            if results != nil {
                if results!.count > 0 {
                    for activity: PFObject in results! {
                        if activity.isAcceptedActivity() {
                            self.myAcceptedActivities.append(activity)
                        }
                        else {
                            self.myJoiningActivities.append(activity)
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var frame = CGRectMake(0, 0, self.view.frame.size.width, 30)
        let view: UIView = UIView(frame: frame)
        view.backgroundColor = Constants.lightBlueColor()
        frame = CGRectMake(10, 7, self.view.frame.size.width - 20, 20)
        let label: UILabel = UILabel(frame: frame)
        view.addSubview(label)
        label.backgroundColor = UIColor.clearColor()
        label.textColor = UIColor.blackColor()
        label.font = UIFont(name: "Lato-Regular", size: 17)

        switch section {
        case 0:
            label.text = "My current activities"
            break
        case 1:
            label.text = "My new activities"
            break
        case 2:
            label.text = "Invitations"
            break
        case 3:
            label.text = "I've requested to join"
            break
        default:
            label.text = ""
            break
        }
        
        return view
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier)! as! ActivitiesCell
        cell.adjustTableViewCellSeparatorInsets(cell)
        var activity: PFObject?
        switch indexPath.section {
        case 0:
            // "My current activities"
            activity = self.myAcceptedActivities[indexPath.row]
            break
        case 1:
            // "My new activities"
            activity = self.myNewActivities[indexPath.row]
            break
        case 2:
            // "Invitations:"
            activity = self.myInvitedActivities[indexPath.row]
            break
        case 3:
            // "I've requested to join:"
            activity = self.myJoiningActivities[indexPath.row]
            break
        default:
            activity = nil
            break
        }

        if activity != nil {
            cell.configureCellForUser(activity!)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            // "My current activities"
            return self.myAcceptedActivities.count
        case 1:
            // "My new activities"
            return self.myNewActivities.count
        case 2:
            // "Invitations:"
            return self.myInvitedActivities.count
        case 3:
            // "I've requested to join:"
            return self.myJoiningActivities.count
        default:
            return 0
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if PFUser.currentUser() == nil {
            self.simpleAlert("Please log in", message: "Log in or create an account to view someone's profile")
            return
        }
        
        var activity: PFObject?
        switch indexPath.section {
        case 0:
            // "My current activities"
            activity = self.myAcceptedActivities[indexPath.row]
            break
        case 1:
            // "My new activities"
            activity = self.myNewActivities[indexPath.row]
            break
        case 2:
            // "Invitations:"
            activity = self.myInvitedActivities[indexPath.row]
            break
        case 3:
            // "I've requested to join:"
            activity = self.myJoiningActivities[indexPath.row]
            break
        default:
            activity = nil
            break
        }
        
        if activity != nil {
            self.goToActivity(activity!)
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
