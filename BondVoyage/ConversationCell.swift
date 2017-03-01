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

protocol ConversationCellDelegate: class {
    func didGetUser(user: User, forConversation conversation: Conversation)
}

class ConversationCell: UITableViewCell {
    @IBOutlet weak var imagePhoto: AsyncImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    weak var delegate: ConversationCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.imagePhoto.layer.cornerRadius = self.imagePhoto.frame.size.width / 2
    }

    var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        return df
    }

    func configureCellForConversation(_ conversation: Conversation) {
        conversation.queryOtherUser { (user, error) in
            guard let user = user, error == nil else {
                print("invalid user")
                self.titleLabel.text = "Unknown"
                self.imagePhoto.image = UIImage(named: "profile")
                self.timeLabel.text = ""
                self.messageLabel.text = ""
                return
            }
            let name = user.displayString
            self.titleLabel.text = name
            if conversation.isUnread {
                self.titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 17)
            }
            else {
                self.titleLabel.font = UIFont(name: "HelveticaNeue", size: 17)
            }
            
            if let photoUrl = user.photoUrl, let url = URL(string: photoUrl) {
                self.imagePhoto.sd_setImage(with: url)
            }
            else {
                self.imagePhoto.image = UIImage(named: "profile")
            }
            
            if let date = conversation.updatedAt {
                let dateString = self.dateFormatter.string(from: date)
                self.timeLabel.text = dateString
            }
            
            self.messageLabel.text = ""
            if let lastMessage = conversation.lastMessage {
                self.messageLabel.text = "\"\(lastMessage)\""
            }
            else {
                if let dialogId = conversation.dialogId {
                    SessionService.sharedInstance.loadDialogMessages(dialogId: dialogId, completion: { (success, messages) in
                        if let message = messages?.first, let text = message.text {
                            self.messageLabel.text = "\"\(text)\""
                        }
                    })
                }
            }
            
            self.delegate?.didGetUser(user: user, forConversation: conversation)
        }
    }
}
