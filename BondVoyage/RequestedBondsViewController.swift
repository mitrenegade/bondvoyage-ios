//
//  MyActivitiesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 2/24/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class RequestedBondsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let kCellIdentifier = "UserCell"
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelNoBonds: UILabel!

    var activities: [PFObject] = []
    var tabIndex: BVTabIndex!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabIndex = .tab_REQUESTED_BONDS

        // configure title bar
        let imageView: UIImageView = UIImageView(image: UIImage(named: "logo-plain")!)
        imageView.frame = CGRect(x: 0, y: 0, width: 150, height: 44)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = Constants.lightBlueColor()
        imageView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: 22)
        self.navigationController!.navigationBar.addSubview(imageView)
        self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()
        
        self.refresh()
        
        NotificationCenter.default.addObserver(self, selector: #selector(RequestedBondsViewController.refreshNotifications), name: NSNotification.Name(rawValue: "activity:updated"), object: nil)
        
        self.setLeftProfileButton()
        let button: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        let image = UIImage(named: "icon-refresh")!.withRenderingMode(.alwaysTemplate)
        button.setImage(image, for: UIControlState())
        button.addTarget(self, action: #selector(RequestedBondsViewController.refresh), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Refresh", style: .Plain, target: self, action: "setup")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh() {
        self.setupWithCompletion(nil)
    }
    
    func refreshNotifications() {
        self.setupWithCompletion(nil)
    }
    
    func setupWithCompletion( _ completion: (()->Void)? ) {
        activities.removeAll()
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.labelNoBonds.isHidden = true
        ActivityRequest.getRequestedBonds { (results, error) in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            // returns activities where the owner of the activity is the user, and someone is requesting a join
            if results != nil {
                self.activities.append(contentsOf: results!)
                if self.activities.count == 0 {
                    self.labelNoBonds.text = "There are currently no bond requests for you."
                    self.labelNoBonds.isHidden = false
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCellIdentifier)! as! UserCell
        cell.adjustTableViewCellSeparatorInsets(cell)
        let activity: PFObject = self.activities[indexPath.row]
        cell.configureCellForActivity(activity)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activities.count
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if PFUser.current() == nil {
            self.simpleAlert("Please log in", message: "Log in or create an account to view someone's profile")
            return
        }
        
        let activity: PFObject = self.activities[indexPath.row]
        self.tableView.isUserInteractionEnabled = false
        self.goToActivity(activity)
        
        // mark activity as seen
        var key: String
        if self.tabIndex == .tab_REQUESTED_BONDS {
            key = "requestedBond:seen:"
        }
        else {
            key = "matchedBond:seen:"
        }
        let id = activity.objectId!
        key = "\(key)\(id)"
        UserDefaults.standard.set(true, forKey: key)
        UserDefaults.standard.synchronize()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "activity:updated"), object: nil)
    }

    func goToActivity(_ activity: PFObject) {
        // join requests exist
        activity.getMatchedUser { (user) in
            self.tableView.isUserInteractionEnabled = true
            if user != nil {
                let controller: UserDetailsViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "UserDetailsViewController") as! UserDetailsViewController
                controller.invitingUser = user
                controller.invitingActivity = activity
                self.navigationController?.pushViewController(controller, animated: true)
            }
            else {
                self.tableView.isUserInteractionEnabled = true
            }
        }
    }
}
