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

protocol UserDetailsDelegate: class {
    func didDeclineInvitation()
}

class UserDetailsViewController: UIViewController {

    var selectedUser: PFUser?
    var invitingUser: PFUser?
    
    @IBOutlet weak var scrollViewContainer: AsyncImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderAndAgeLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var interestsView: UIView!
    @IBOutlet weak var constraintNameViewTopOffset: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var relevantInterests: [String]?
    var invitingMatch: PFObject?

    weak var delegate: UserDetailsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nameView.hidden = true
        self.interestsView.hidden = true
        
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
        
        self.nameLabel!.layer.shadowOpacity = 1
        self.nameLabel!.layer.shadowRadius = 2
        self.nameLabel!.layer.shadowColor = UIColor.blackColor().CGColor
        self.nameLabel!.layer.shadowOffset = CGSizeMake(1, 1)
        
        self.view!.backgroundColor = UIColor.clearColor()
    }

    func configureUI() {
        self.title = "Invite"
        self.nameView.backgroundColor = UIColor.BV_backgroundGrayColor()
        self.interestsView.backgroundColor = UIColor.BV_backgroundGrayColor()
        self.constraintNameViewTopOffset.constant = self.view.frame.size.height - self.nameView.frame.size.height - self.interestsView.frame.size.height
        self.scrollViewContainer.contentMode = .ScaleAspectFill
        
        if self.invitingUser != nil {
            self.title = "Invitation"
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Decline", style: .Done, target: self, action: "declineInvitation")
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Accept", style: .Done, target: self, action: "acceptInvitation")
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
        
        self.nameView.hidden = false
        self.interestsView.hidden = false

        if let photoURL: String = user!.valueForKey("photoUrl") as? String {
            self.scrollViewContainer.imageURL = NSURL(string: photoURL)
        }
        else if let photo: PFFile = user!.valueForKey("photo") as? PFFile {
            self.scrollViewContainer.imageURL = NSURL(string: photo.url!)
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
    }

    func configureInterestsLabel() {
        var user: PFUser? = selectedUser
        if self.selectedUser == nil {
            user = self.invitingUser
        }
        if user == nil {
            return
        }

        if self.invitingMatch != nil {
            self.invitingMatch!.fetchInBackgroundWithBlock({ (object, error) -> Void in
                if let categories: [String] = self.invitingMatch!.objectForKey("categories") as? [String] {
                    let str = self.stringFromArray(categories)
                    if self.selectedUser != nil {
                        self.interestsLabel.text = "Interests: \(str)"
                    }
                    else {
                        self.interestsLabel.text = "Wants to bond over: \(str)" // todo: load match and set this to match category
                    }
                }
            })
        }
        else {
            self.interestsLabel.text = nil
        }

        if let about = user!.valueForKey("about") as? String {
            self.aboutMeLabel.text = "About me: \(about)"
        }
        else {
            self.aboutMeLabel.text = nil
        }
    }

    func dismiss() {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func acceptInvitation() {
        let toMatch: PFObject = self.invitingMatch!.valueForKey("inviteTo") as! PFObject
        MatchRequest.respondToInvite(self.invitingMatch!, toMatch: toMatch, responseType: "accepted") { (results, error) -> Void in
            if error != nil {
                self.simpleAlert("Could not accept invitation", defaultMessage: "Please try again", error: error)
            }
            else {
                self.goToPlaces()
            }
        }
    }
    
    func declineInvitation() {
        let toMatch: PFObject = self.invitingMatch!.valueForKey("inviteTo") as! PFObject
        MatchRequest.respondToInvite(self.invitingMatch!, toMatch: toMatch, responseType: "declined") { (results, error) -> Void in
            if error != nil {
                self.simpleAlert("Could not decline invitation", defaultMessage: "Please try again", error: error)
            }
            else {
                self.close()
            }
        }
    }
    
    func goToPlaces() {
        let controller: PlacesViewController = UIStoryboard(name: "Places", bundle: nil).instantiateViewControllerWithIdentifier("placesID") as! PlacesViewController
        controller.relevantInterests = self.relevantInterests
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func close() {
        // close modally
        if self.delegate != nil {
            self.delegate!.didDeclineInvitation()
        }
        else {
            self.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
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
