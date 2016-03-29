//
//  UserCell.swift
//  BondVoyage
//
//  Created by Bobby Ren on 3/29/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import AsyncImageView
import Parse

class UserCell: UITableViewCell {

    @IBOutlet weak var viewFrame: UIView!
    @IBOutlet weak var imagePhoto: AsyncImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var shadowLayer: CALayer?
    var activity: PFObject?
    
    func configureCellForActivity(activity: PFObject) {
        self.imagePhoto.crossfadeDuration = 0
        
        self.activity = activity
        
        self.viewFrame!.layer.shadowOpacity = 1
        self.viewFrame!.layer.shadowRadius = 5
        self.viewFrame!.layer.shadowColor = UIColor.blackColor().CGColor
        self.viewFrame!.layer.shadowOffset = CGSizeMake(3, 3)
        
        /*
        self.titleLabel!.layer.shadowOpacity = 1
        self.titleLabel!.layer.shadowRadius = 3
        self.titleLabel!.layer.shadowColor = UIColor.blackColor().CGColor
        self.titleLabel!.layer.shadowOffset = CGSizeMake(3, 3)
        */
        
        if self.activity != nil {
            if !self.activity!.isOwnActivity() {
                let user: PFUser = self.activity!.objectForKey("user") as! PFUser
                user.fetchInBackgroundWithBlock { (object, error) -> Void in
                    self.titleLabel.text = self.activity!.shortTitle()
                    if let photoURL: String = object!.valueForKey("photoUrl") as? String {
                        self.imagePhoto.imageURL = NSURL(string: photoURL)
                    }
                    else {
                        self.imagePhoto.image = UIImage(named: "profile-icon")
                    }
                }
            }
            else {
                // join requests exist
                if let userIds: [String] = self.activity!.objectForKey("joining") as? [String] {
                    let userId = userIds[0]
                    let query: PFQuery = PFUser.query()!
                    query.whereKey("objectId", equalTo: userId)
                    query.findObjectsInBackgroundWithBlock { (results, error) -> Void in
                        if results != nil && results!.count > 0 {
                            let user: PFUser = results![0] as! PFUser
                            if let name: String = user.objectForKey("firstName") as? String {
                                var categoryTitle: String = ""
                                if self.activity!.category() != nil {
                                    categoryTitle = " over \(CategoryFactory.categoryReadableString(self.activity!.category()!))"
                                }
                                self.titleLabel.text = "\(name) wants to bond\(categoryTitle)"
                            }
                            
                            if let photoURL: String = user.objectForKey("photoUrl") as? String {
                                self.imagePhoto.imageURL = NSURL(string: photoURL)
                            }
                        }
                    }
                }
            }
        }
        else {
            self.imagePhoto.image = UIImage(named: "profile-icon")
        }
    }
}
