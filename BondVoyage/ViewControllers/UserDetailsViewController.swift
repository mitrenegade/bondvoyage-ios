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

    var selectedUser: PFUser?
    var invitingUser: PFUser?
    
    @IBOutlet weak var scrollViewContainer: AsyncImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderAndAgeLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var interestsView: UIView!
    @IBOutlet weak var interestsToTransparentViewSpacingConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var relevantInterests: [String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.selectedUser != nil {
            self.selectedUser!.fetchInBackgroundWithBlock({ (user, error) -> Void in
                self.configureDetailsForUser()
            })
        }
        else if self.invitingUser != nil {
            self.invitingUser!.fetchInBackgroundWithBlock({ (user, error) -> Void in
                self.configureDetailsForUser()
            })
        }
        self.configureUI()
    }

    func configureUI() {
        self.title = "Invite"
        self.transparentView.backgroundColor = UIColor.clearColor()
        self.nameView.backgroundColor = UIColor.BV_backgroundGrayColor()
        self.interestsView.backgroundColor = UIColor.BV_backgroundGrayColor()
        self.interestsToTransparentViewSpacingConstraint.constant = self.nameView.bounds.height // I don't know why there is a 2 pixel gap between views
        self.scrollViewContainer.contentMode = .ScaleAspectFill
        
        if self.invitingUser != nil {
            self.title = "Accept"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: "close")
        }
    }

    func configureDetailsForUser() {
        var user: PFUser? = selectedUser
        if self.selectedUser == nil {
            user = self.invitingUser
        }
        if user == nil {
            return
        }
        
        if let photoURL: String = user!.valueForKey("photoUrl") as? String {
            self.scrollViewContainer.imageURL = NSURL(string: photoURL)
        }
        else {
            self.scrollViewContainer.image = UIImage(named: "profile-icon")
        }

        let firstName = user!.valueForKey("firstName")!
        self.nameLabel.text = "\(firstName)"

        let currentYear = components.year
        let age = currentYear - (user!.valueForKey("birthYear") as! Int)
        self.genderAndAgeLabel.text = "\(user!.valueForKey("gender")!), age: \(age)"

        self.configureInterestsLabel()

        self.aboutMeLabel.text = "About me: Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
    }

    func configureInterestsLabel() {
        var user: PFUser? = selectedUser
        if self.selectedUser == nil {
            user = self.invitingUser
        }
        if user == nil {
            return
        }

        let interests = user!.valueForKey("interests")!
        if self.selectedUser != nil {
            self.interestsLabel.text = "Interests: \(stringFromArray(interests as! Array<String>))"
        }
        else {
            self.interestsLabel.text = "Wants to bond over: \(stringFromArray(interests as! Array<String>))"
        }
    }
    func dismiss() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    @IBAction func pimaryActionButtonPressed(sender: UIButton) {
        if self.selectedUser != nil {
            print("User pressed invite to bond")
            var interests: [String] = []
            if self.relevantInterests != nil {
                interests = self.relevantInterests!
            }
            else if self.selectedUser!.objectForKey("interests") != nil {
                interests = self.selectedUser!.objectForKey("interests") as! [String]
            }
            
            self.activityIndicator.startAnimating()
            UserRequest.inviteUser(self.selectedUser!, interests: interests) { (success, error) -> Void in
                self.activityIndicator.stopAnimating()
                if success {
                    print("Success! User was invited")
                    self.simpleAlert("Invite sent!", message: "You have sent an invitation to bond to \(self.selectedUser!.objectForKey("firstName")!)", completion: { () -> Void in
                        self.dismiss()
                    })
                }
                else {
                    print("Error! Push failed: \(error)")
                    self.simpleAlert("Could not invite", defaultMessage: "There was an error sending an invitation.", error: error)
                }
            }
        }
        else {
            print("User pressed accept invitation to bond")
            // TODO: add UserRequest.acceptInvitation call
            let controller: PlacesViewController = UIStoryboard(name: "Places", bundle: nil).instantiateViewControllerWithIdentifier("placesID") as! PlacesViewController
            controller.relevantInterests = self.relevantInterests
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

    func close() {
        // close modally
        self.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
