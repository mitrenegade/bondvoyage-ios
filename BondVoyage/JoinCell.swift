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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithActivity(_ activity: PFObject, user: PFUser?, place: String?) {
        let imageView: AsyncImageView = self.viewWithTag(1) as! AsyncImageView
        let labelName: UILabel = self.viewWithTag(2) as! UILabel
        let labelPlace: UILabel = self.viewWithTag(3) as! UILabel
        
        var name: String?
        if user != nil {
            name = user!.value(forKey: "firstName") as? String
            if name == nil {
                name = user!.value(forKey: "lastName") as? String
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
                        if user!.objectId! == PFUser.current()?.objectId! {
                            labelName.text = "Your invitation was accepted"
                        }
                    }
                }
                else {
                    if user!.objectId! == PFUser.current()?.objectId! {
                        labelName.text = "Your have sent an invitation"
                    }
                }
            }
            
            if let url: String = user?.object(forKey: "photoUrl") as? String {
                //imageView.imageURL = NSURL(string: url)
                imageView.setValue(URL(string:url), forKey: "imageURL")
            }
            
            imageView.layer.cornerRadius = imageView.frame.size.width / 2
            imageView.contentMode = .scaleAspectFill
        }
        
        if place != nil {
            labelPlace.text = "at \(place!)"
        }
    }

}
