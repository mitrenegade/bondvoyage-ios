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
    @IBOutlet weak var messageLabel: UILabel!
    
    var shadowLayer: CALayer?
    var activity: PFObject?
        
    func configureCellForActivity(_ activity: PFObject) {
        self.imagePhoto.crossfadeDuration = 0
        
        self.activity = activity
        
        self.viewFrame!.layer.shadowOpacity = 1
        self.viewFrame!.layer.shadowRadius = 5
        self.viewFrame!.layer.shadowColor = UIColor.black.cgColor
        self.viewFrame!.layer.shadowOffset = CGSize(width: 3, height: 3)
        
        if self.activity != nil {
            self.activity?.getMatchedUser({ (user) in
                if self.activity!.isOwnActivity() {
                    if let name: String = user!.object(forKey: "firstName") as? String {
                        let categoryString = CategoryFactory.categoryReadableString(self.activity!.category()!)
                        if self.activity!.isAcceptedActivity() {
                            if self.activity!.category() != nil {
                                self.titleLabel.text = "\(categoryString) with \(name)"
                            }
                            else {
                                self.titleLabel.text = "Bond with \(name)"
                            }
                        }
                        else {
                            var categoryTitle: String = ""
                            if self.activity!.category() != nil {
                                categoryTitle = " over \(categoryString)"
                            }
                            self.titleLabel.text = "\(name) wants to bond\(categoryTitle)"
                        }
                    }
                    
                    if let photoURL: String = user!.object(forKey: "photoUrl") as? String {
                        self.imagePhoto.setValue(URL(string:photoURL), forKey: "imageURL")
                        //self.imagePhoto.imageURL = NSURL(string: photoURL)
                    }
                }
                else {
                    self.titleLabel.text = self.activity!.shortTitle()
                    if let photoURL: String = user!.value(forKey: "photoUrl") as? String {
                        self.imagePhoto.setValue(URL(string:photoURL), forKey: "imageURL")
                        //self.imagePhoto.imageURL = NSURL(string: photoURL)
                    }
                    else {
                        self.imagePhoto.image = UIImage(named: "profile")
                    }
                }
            })
        }
        else {
            self.imagePhoto.image = UIImage(named: "profile")
        }
    }
}
