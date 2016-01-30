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
    @IBOutlet weak var profileImage: AsyncImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var genderAndAgeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    func configureCellForUser(user: PFUser) {
        let currentYear = components.year
        let age = currentYear - (user.valueForKey("birthYear") as! Int)
        
        var name: String? = user.valueForKey("firstName") as? String
        if name == nil {
            name = user.valueForKey("lastName") as? String
        }
        if name == nil {
            name = user.username
        }
        self.usernameLabel.text = name
        self.genderAndAgeLabel.text = "\(user.valueForKey("gender")!), age: \(age)"
        
        var info: String? = nil
        if let interests: [String] = user.valueForKey("interests") as? [String] {
            if interests.count > 0 {
                info = "Likes: \(interests[0])"
                if interests.count > 1 {
                    for var i=1; i < interests.count; i++ {
                        info = "\(info!), \(interests[i])"
                    }
                }
            }
        }
        self.infoLabel.text = info
        
        if let photoURL: String = user.valueForKey("photoUrl") as? String {
            self.profileImage.imageURL = NSURL(string: photoURL)
        }
        else {
            self.profileImage.image = UIImage(named: "profile-icon")
        }
        
        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.layer.borderColor = Constants.blueColor().CGColor
        self.profileImage.layer.borderWidth = 2
    }
}
