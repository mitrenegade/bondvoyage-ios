//
//  ChatListViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 11/21/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse
import ParseLiveQuery

class ChatListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelNoBonds: UILabel!

    // live query for Parse objects
    let liveQueryClient = ParseLiveQuery.Client()
    var subscription: Subscription<Conversation>?
    var isSubscribed: Bool = false

    var conversations: [Conversation]?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // configure title bar
        let imageView: UIImageView = UIImageView(image: UIImage(named: "logo-plain")!)
        imageView.frame = CGRect(x: 0, y: 0, width: 150, height: 44)
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = Constants.lightBlueColor()
        imageView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: 22)
        self.navigationController!.navigationBar.addSubview(imageView)
        self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()

        // Do any additional setup after loading the view.
        self.loadConversations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadConversations() {
        print("Load chats")
        guard let user = PFUser.current(), let userId = user.objectId else { return }
        guard let query: PFQuery<Conversation> = Conversation.query() as? PFQuery<Conversation> else { return }
        query.whereKey("participantIds", contains: userId)
        query.findObjectsInBackground { (results, error) in
            self.conversations = results
            print("conversations loaded \(results?.count)")
            self.tableView.reloadData()
            
            self.subscribeToUpdates()
        }
    }

    func subscribeToUpdates() {
        guard let user = PFUser.current(), let userId = user.objectId else { return }
        guard let query: PFQuery<Conversation> = Conversation.query() as? PFQuery<Conversation> else { return }
        query.whereKey("participantIds", contains: userId)
        
        self.subscription = liveQueryClient.subscribe(query)
            .handle(Event.updated, { (_, object) in
                if let conversations = self.conversations {
                    for c in conversations {
                        if c.objectId == object.objectId {
                            self.conversations!.remove(at: conversations.index(of: c)!)
                            self.conversations!.append(object)
                        }
                    }
                }
                DispatchQueue.main.async(execute: {
                    print("received update for conversations: \(object.objectId!)")
                })
            })
        isSubscribed = true
    }
}

extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell")! as! UserCell
        cell.adjustTableViewCellSeparatorInsets(cell)

        guard let conversations = self.conversations, indexPath.row < conversations.count else { return cell }
        let conversation: Conversation = conversations[indexPath.row]

        cell.configureCellForConversation(conversation)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations?.count ?? 0
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if PFUser.current() == nil {
            self.simpleAlert("Please log in", message: "Log in or create an account to view someone's profile")
            return
        }
        
        guard let conversations = self.conversations, indexPath.row < conversations.count else { return }
        let conversation: Conversation = conversations[indexPath.row]
        
        self.tableView.isUserInteractionEnabled = false
        //self.goToChat(conversation)
    }
    
    func goToChat(_ selectedUser: PFUser, conversation: Conversation?) {
        /*
        guard let currentUser = PFUser.current(), let currentUserId = currentUser.objectId, let selectedUserId = selectedUser.objectId else {
            print("goToChat failed")
            return
        }
        
        QBUserService.getQBUUserFor(selectedUser) { [weak self] user in
            guard let user = user else {
                print("no user")
                return
            }
            SessionService.sharedInstance.startChatWithUser(user, completion: { (success, dialog) in
                guard success else {
                    print("Could not start chat")
                    self?.simpleAlert("Could not start chat", defaultMessage: "There was an error starting a chat with this person", error: nil, completion: nil)
                    return
                }
                
                if let chatNavigationVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatNavigationViewController") as? UINavigationController,
                    let chatVC = chatNavigationVC.viewControllers[0] as? ChatViewController {
                    chatVC.dialog = dialog
                    self?.present(chatNavigationVC, animated: true, completion: {
                        //QBNotificationService.sharedInstance.currentDialogID = dialog?.ID!
                        // create conversation
                        if let dialogId = dialog?.id {
                            print("add dialog to conversation")
                            conversation?.setValue(dialogId, forKey: "dialogId")
                            conversation?.saveInBackground()
                        }
                    })
                }
            })
        }
        */
    }
}
