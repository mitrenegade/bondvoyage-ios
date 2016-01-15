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
    var selectedUser: PFUser!

    @IBOutlet weak var scrollViewContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.title = "INVITE"
        self.configureDetailsForUser()
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

}
