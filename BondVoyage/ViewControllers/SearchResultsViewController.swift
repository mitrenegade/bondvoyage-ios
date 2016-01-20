//
//  SearchResultsViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/23/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit
import Parse
import AsyncImageView

protocol SearchResultsDelegate {
    func showUserDetails(user: PFUser?)
}

let date = NSDate()
let calendar = NSCalendar.currentCalendar()
let components = calendar.components([.Day , .Month , .Year], fromDate: date)

let kSearchResultCellIdentifier = "searchResultCell"

class UserSearchResultCell: UITableViewCell {

    @IBOutlet weak var profileImage: AsyncImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var genderAndAgeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    func configureCellForUser(user: PFUser) {
        let currentYear = components.year
        let age = currentYear - (user.valueForKey("birthYear") as! Int)

        var name: String? = user.valueForKey("firstName") as? String
        if name == nil {
            name = user.valueForKey("lastName") as? String
        }
        if name == nil {
            name = user.username
        }
        self.usernameLabel.text = name
        self.genderAndAgeLabel.text = "\(user.valueForKey("gender")!), age: \(age)"

        var info: String? = nil
        if let interests: [String] = user.valueForKey("interests") as? [String] {
            if interests.count > 0 {
                info = "Likes: \(interests[0])"
                if interests.count > 1 {
                    for var i=1; i < interests.count; i++ {
                        info = "\(info!), \(interests[i])"
                    }
                }
            }
        }
        self.infoLabel.text = info

        if let photoURL: String = user.valueForKey("photoUrl") as? String {
            self.profileImage.imageURL = NSURL(string: photoURL)
        }
        else {
            self.profileImage.image = UIImage(named: "profile-icon")
        }

        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.layer.borderColor = Constants.blueColor().CGColor
        self.profileImage.layer.borderWidth = 2
    }
}


class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    var users: [PFUser]?

    var delegate: SearchResultsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if PFUser.currentUser() == nil {
            self.simpleAlert("Log in?", message: "Log in or create an account to view someone's profile")
            return
        }
        
        let user = users![indexPath.row]
        self.delegate?.showUserDetails(user)
    }

    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kSearchResultCellIdentifier)! as! UserSearchResultCell
        cell.adjustTableViewCellSeparatorInsets(cell)
        if users != nil {
            cell.configureCellForUser(users![indexPath.row])
        }
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numUsers: Int = users?.count {
            return numUsers
        }
        else {
            print("No users found")
            return 0
        }
    }
}
