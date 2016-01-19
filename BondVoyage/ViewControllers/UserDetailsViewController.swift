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
    @IBOutlet weak var scrollViewContainer: AsyncImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderAndAgeLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var interestsView: UIView!
    @IBOutlet weak var inviteToBondButton: UIButton!
    @IBOutlet weak var interestsToTransparentViewSpacingConstraint: NSLayoutConstraint!

    var relevantInterests: [String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDetailsForUser()
        self.configureUI()
    }

    func configureUI() {
        self.title = "Invite"
        self.inviteToBondButton.backgroundColor = UIColor.BV_primaryActionBlueColor()
        self.transparentView.backgroundColor = UIColor.clearColor()
        self.nameView.backgroundColor = UIColor.BV_backgroundGrayColor()
        self.interestsView.backgroundColor = UIColor.BV_backgroundGrayColor()
        self.interestsToTransparentViewSpacingConstraint.constant = (self.nameView.bounds.height - 1) // I don't know why there is a 2 pixel gap between views
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

        self.configureInterestsLabel()

        self.aboutMeLabel.text = "About me: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    }

    func close() {
        // close modally
        self.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func configureInterestsLabel() {
        let interests = self.selectedUser.valueForKey("interests")!
        self.interestsLabel.text = "Interests: \(stringFromArray(interests as! Array<String>))"
    }

    @IBAction func pimaryActionButtonPressed(sender: UIButton) {
        print("User pressed invite to bond")
        if self.selectedUser != nil {
            var interests: [String] = []
            if self.relevantInterests != nil {
                interests = self.relevantInterests!
            }
            else if self.selectedUser!.objectForKey("interests") != nil {
                interests = self.selectedUser!.objectForKey("interests") as! [String]
            }
            
            UserRequest.inviteUser(self.selectedUser, interests: interests) { (success, error) -> Void in
                if success {
                    print("Success! User was invited")
                }
                else {
                    print("Error! Push failed: \(error)")
                }
            }
        }
        else if self.invitingUser != nil {
            // TODO: add UserRequest.acceptInvitation call
            let controller: PlacesViewController = UIStoryboard(name: "Places", bundle: nil).instantiateViewControllerWithIdentifier("placesID") as! PlacesViewController
            controller.relevantInterests = self.relevantInterests
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    // MARK: - Helper Methods

    func stringFromArray(arr: Array<String>) -> String {
        var interestsString = String()
        for interest in arr {
            if interestsString.characters.count == 0 {
                interestsString = interest
            } else {
                interestsString = interestsString + ", " + interest
            }
        }
        return interestsString
    }
}
