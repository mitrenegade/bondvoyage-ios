//
//  JoinCell.swift
//  BondVoyage
//
//  Created by Bobby Ren on 3/30/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse
import AsyncImageView

class JoinCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithActivity(activity: PFObject, user: PFUser?, place: BVPlace?) {
        let imageView: AsyncImageView = self.viewWithTag(1) as! AsyncImageView
        let labelName: UILabel = self.viewWithTag(2) as! UILabel
        let labelPlace: UILabel = self.viewWithTag(3) as! UILabel
        
        var name: String?
        if user != nil {
            name = user!.valueForKey("firstName") as? String
            if name == nil {
                name = user!.valueForKey("lastName") as? String
            }
            if name == nil {
                name = user!.username
            }
            
            if name != nil {
                labelName.text = "\(name!) wants to meet up"
                if activity.isAcceptedActivity() {
                    if activity.isOwnActivity() {
                        labelName.text = "You are meeting \(name!)"
                    }
                    else {
                        if user!.objectId! == PFUser.currentUser()?.objectId! {
                            labelName.text = "Your invitation was accepted"
                        }
                    }
                }
                else {
                    if user!.objectId! == PFUser.currentUser()?.objectId! {
                        labelName.text = "Your have sent an invitation"
                    }
                }
            }
            
            if let url: String = user?.objectForKey("photoUrl") as? String {
                imageView.imageURL = NSURL(string: url)
            }
            
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.contentMode = .ScaleAspectFill
        }
        
        if place?.name != nil {
            labelPlace.text = "at \(place!.name!)"
        }
    }

}
