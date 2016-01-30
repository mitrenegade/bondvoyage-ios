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
    
    var match: PFObject?
    
    func configureCellForUser(match: PFObject) {
        self.bgImage.crossfadeDuration = 0

        self.match = match
        let user: PFUser = match.objectForKey("user") as! PFUser
        
        let category = (self.match!.objectForKey("categories") as! [String])[0].capitalizeFirst
        let city: String? = self.match!.objectForKey("city") as? String
        
        self.viewFrame!.layer.shadowOpacity = 1
        self.viewFrame!.layer.shadowRadius = 5
        self.viewFrame!.layer.shadowColor = UIColor.blackColor().CGColor
        self.viewFrame!.layer.shadowOffset = CGSizeMake(3, 3)

        self.titleLabel!.layer.shadowOpacity = 1
        self.titleLabel!.layer.shadowRadius = 3
        self.titleLabel!.layer.shadowColor = UIColor.blackColor().CGColor
        self.titleLabel!.layer.shadowOffset = CGSizeMake(3, 3)

        self.bgImage.image = CategoryFactory.subcategoryBgImage(category)
        
        user.fetchInBackgroundWithBlock { (object, error) -> Void in
            var name: String? = user.valueForKey("firstName") as? String
            if name == nil {
                name = user.valueForKey("lastName") as? String
            }
            if name == nil {
                name = user.username
            }
            
            var title = "\(category)"
            if name != nil && city != nil {
                title = "\(category) with \(name!) in \(city!)"
            }
            else if name != nil {
                title = "\(title) with \(name!)"
            }
            else if city != nil {
                title = "\(title) in \(city!)"
            }
            
            self.titleLabel.text = title
        }
    }
}
