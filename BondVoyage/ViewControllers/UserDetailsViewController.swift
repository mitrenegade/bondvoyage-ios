//
//  UserDetailsViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/8/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse
import AsyncImageView

class UserDetailsViewController: UIViewController {

    var selectedUser: PFUser!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderAndAgeLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var scrollViewContainer: AsyncImageView!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var interestsView: UIView!
    @IBOutlet weak var inviteToBondButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDetailsForUser()
        self.configureUI()
    }

    func configureUI() {
        self.title = "Invite"
        self.inviteToBondButton.backgroundColor = UIColor.BV_primaryActionBlueColor()
        self.transparentView.backgroundColor = UIColor.clearColor()
        self.transparentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))
        print("\(self.transparentView.frame.height)")
        self.nameView.backgroundColor = UIColor.BV_backgroundGrayColor()
        self.interestsView.backgroundColor = UIColor.BV_backgroundGrayColor()
    }

    override func viewWillAppear(animated: Bool) {

    }

    @IBAction func inviteToBondButtonPressed(sender: UIButton) {

    }

    func configureDetailsForUser() {
        if let photoURL: String = selectedUser.valueForKey("photoUrl") as? String {
            self.scrollViewContainer.imageURL = NSURL(string: photoURL)
        }
        else {
            self.scrollViewContainer.image = UIImage(named: "profile-icon")
        }

        let firstName = self.selectedUser.valueForKey("firstName")!
        self.nameLabel.text = "\(firstName)"

        let currentYear = components.year
        let age = currentYear - (self.selectedUser.valueForKey("birthYear") as! Int)
        self.genderAndAgeLabel.text = "\(self.selectedUser.valueForKey("gender")!), age: \(age)"


        let interests = self.selectedUser.valueForKey("interests")!
        self.interestsLabel.text = "Interests: \(interests)"
        
    }



}
