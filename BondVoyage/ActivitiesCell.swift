//
//  ActivitiesCell.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/30/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import AsyncImageView
import Parse

class ActivitiesCell: UITableViewCell {
    @IBOutlet weak var viewFrame: UIView!
    @IBOutlet weak var bgImage: AsyncImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var shadowLayer: CALayer?
    
    var activity: PFObject?
    
    func configureCellForUser(activity: PFObject) {
        self.bgImage.crossfadeDuration = 0

        self.activity = activity
        
        self.viewFrame!.layer.shadowOpacity = 1
        self.viewFrame!.layer.shadowRadius = 5
        self.viewFrame!.layer.shadowColor = UIColor.blackColor().CGColor
        self.viewFrame!.layer.shadowOffset = CGSizeMake(3, 3)

        self.titleLabel!.layer.shadowOpacity = 1
        self.titleLabel!.layer.shadowRadius = 3
        self.titleLabel!.layer.shadowColor = UIColor.blackColor().CGColor
        self.titleLabel!.layer.shadowOffset = CGSizeMake(3, 3)

        self.bgImage.image = self.activity!.defaultImage()
        
        let user: PFUser = self.activity!.objectForKey("user") as! PFUser
        user.fetchInBackgroundWithBlock { (object, error) -> Void in
            self.titleLabel.text = self.activity!.shortTitle()
        }
    }
}
