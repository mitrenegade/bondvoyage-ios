//
//  UserDetailsViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/8/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class UserDetailsViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderAndAgeLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    
    @IBOutlet weak var buttonInvite: UIButton!
    
    var selectedUser: PFUser!
    var invitingUser: PFUser!
    var relevantInterests: [String]?
    
    @IBOutlet weak var scrollViewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "INVITE"
        
        if self.invitingUser != nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Done, target: self, action: "close")
        }
        
        // configure invite
        if self.invitingUser != nil {
            self.buttonInvite.setTitle("ACCEPT INVITATION", forState: .Normal)
        }
        else {
            self.configureDetailsForUser()
        }
    }

    override func viewWillAppear(animated: Bool) {
//        self.automaticallyAdjustsScrollViewInsets = true; // this doesn't solve the problem

        // TODO: this view is pushed from an embedded view controller, and therefore will take the height of its container view. Therefore, there is a giant white gap that is the height of the navigation bar + search bar in the hereandnow viewcontroller that embedded the view controller. Must figure out a way to get around this--either by reconstraining the top of the scroll view to the navigation bar's bottom in view will appear (doesnt work because the scroll view and the nav bar are in different hierarchies), or making the constant of the scroll view's top constraint to the difference between the containerview and the top layout guide in the parent vc that embedded them. no other ways come to mind so far but i'm sure they exist

        //self.scrollViewContainer.topAnchor.constraintEqualToAnchor(self.navigationController?.navigationBar.topAnchor).active = true

        // the above doesnt work because the nav bar and the scroll view is in a diff hierarchy, the constraint cannot be done
    }

    func configureDetailsForUser() {
        let firstName = self.selectedUser.valueForKey("firstName")!
        self.nameLabel.text = "\(firstName)"
    }

    func close() {
        // close modally
        self.navigationController?.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Invite to bond
    @IBAction func didClickInvite(sender: UIButton) {
        if self.selectedUser != nil {
            var interests: [String]? = self.relevantInterests
            if interests == nil {
                interests = self.selectedUser!.objectForKey("interests") as? [String]
            }
            if interests == nil {
                interests = []
            }
            
            UserRequest.inviteUser(self.selectedUser, interests: interests!) { (success, error) -> Void in
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
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }

}
