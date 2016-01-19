//
//  acceptInvitationViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/17/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class AcceptInvitationViewController: UserDetailsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.inviteToBondButton.titleLabel?.text = "ACCEPT INVITATION"
    }

    override func configureInterestsLabel() {
        let interests = self.selectedUser.valueForKey("interests")!
        self.interestsLabel.text = "Wants to bond over: \(stringFromArray(interests as! Array<String>))"
    }

    @IBAction override func pimaryActionButtonPressed(sender: UIButton) {
        print("User pressed accept invitation to bond")
    }

}
