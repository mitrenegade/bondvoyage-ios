//
//  ConversationCell.swift
//  BondVoyage
//
//  Created by Bobby Ren on 11/26/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import AsyncImageView
import Parse

class ConversationCell: UITableViewCell {
    @IBOutlet weak var imagePhoto: AsyncImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imagePhoto.layer.cornerRadius = self.imagePhoto.frame.size.width / 2
    }

    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MM/dd"
        return df
    }

    func configureCellForConversation(_ conversation: Conversation) {
        guard var userIds = conversation.participantIds as? [String] else {
            return
        }
        guard let currentUser = PFUser.current(), let currentUserId = currentUser.objectId else { return }
        print("all userids: \(userIds)")
        if let index = userIds.index(of: currentUserId) {
            userIds.remove(at: index)
            print("other userId: \(userIds)")
        }
        guard userIds.count > 0, let userId = userIds.first else { return }
        
        let query = PFUser.query()
        query?.whereKey("objectId", equalTo: userId)
        query?.findObjectsInBackground(block: { (results, error) in
            if let error = error {
                // TODO: handle error
                print("error \(error)")
                return
            }
            
            if let users = results as? [PFUser], users.count > 0, let user = users.first as? User {
                let name = user.displayString
                self.titleLabel.text = name
                
                if let photoUrl = user.photoUrl, let url = URL(string: photoUrl) {
                    self.imagePhoto.sd_setImage(with: url)
                }
                
                if let date = conversation.updatedAt {
                    let dateString = self.dateFormatter.string(from: date)
                    self.timeLabel.text = dateString
                }
            }
            else {
                print("no user found")
                // handle error
            }
        })
    }
}
