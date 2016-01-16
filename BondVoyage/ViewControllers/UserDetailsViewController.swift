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

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderAndAgeLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var scrollViewContainer: AsyncImageView!
    var selectedUser: PFUser!

    
    @IBOutlet weak var inviteToBondButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDetailsForUser()
        self.title = "Invite"
        self.inviteToBondButton.backgroundColor = UIColor.BV_primaryActionBlueColor()
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

        let interests = self.selectedUser.valueForKey("interests")!
        self.interestsLabel.text = "Interests: \(interests)"
        
    }



}
