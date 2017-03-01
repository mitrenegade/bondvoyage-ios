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
    var conversationSections: [String] = [String]()
    
    var users:[Conversation: User] = [Conversation: User]()
    
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
        
        self.setLeftProfileButton()

        // Do any additional setup after loading the view.
        self.loadConversations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadConversations() {
        print("Load chats")
        Conversation.queryConversations(unread: false) {(results, error) in
            if let error = error {
                self.simpleAlert("Error loading messages", defaultMessage: "There was an error loading your previous conversations.", error: error)
            }
            else {
                self.conversations = results
                self.refreshConversationSections()
                self.tableView.reloadData()
                self.subscribeToUpdates()
            }
        }
    }
    
    func refreshConversationSections() {
        self.conversationSections.removeAll()
        if let conversations = self.conversations, conversations.count > 0 {
            for conversation in conversations {
                let dateString = conversation.dateString
                if !self.conversationSections.contains(dateString) {
                    self.conversationSections.append(dateString)
                }
            }
            self.conversationSections.sort(by: { (a, b) -> Bool in
                return a > b
            })
        }
        print("conversation sections \(self.conversationSections.count)")
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
                        }
                    }
                    self.conversations!.append(object)
                }
                DispatchQueue.main.async(execute: {
                    print("received update for conversations: \(object.objectId!)")
                    self.refreshConversationSections()
                    self.tableView.reloadData()
                })
            })
        isSubscribed = true
    }
}

extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return conversationSections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return conversationSections[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionName = self.conversationSections[section]
        let conversationsFromDay = conversations?.filter { (c) -> Bool in
            c.dateString == sectionName
        }
        return conversationsFromDay?.count ?? 0
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell")! as! ConversationCell
        cell.adjustTableViewCellSeparatorInsets(cell)
        cell.delegate = self

        guard let conversations = self.conversations, indexPath.section < conversationSections.count else  { return cell }
        let sectionName = self.conversationSections[indexPath.section]
        let conversationsFromDay = conversations.filter { (c) -> Bool in
            c.dateString == sectionName
        }.sorted { (c1, c2) -> Bool in
            guard c1.updatedAt != nil else { return false }
            guard c2.updatedAt != nil else { return true }
            return c1.updatedAt! > c2.updatedAt!
        }
        let conversation: Conversation = conversationsFromDay[indexPath.row]

        cell.configureCellForConversation(conversation)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if PFUser.current() == nil {
            self.simpleAlert("Please log in", message: "Log in or create an account to view someone's profile")
            return
        }
        
        guard let conversations = self.conversations, indexPath.section < conversationSections.count else  { return }
        let sectionName = self.conversationSections[indexPath.section]
        let conversationsFromDay = conversations.filter { (c) -> Bool in
            c.dateString == sectionName
            }.sorted { (c1, c2) -> Bool in
                c1.updatedAt! > c2.updatedAt!
        }
        let conversation: Conversation = conversationsFromDay[indexPath.row]
        
        if let user = self.users[conversation] {
            self.goToChat(user, conversation: conversation)
        }
        else {
            conversation.queryOtherUser { (user, error) in
                guard let user = user, error == nil else {
                    return
                }
                self.didGetUser(user: user, forConversation: conversation)
                self.goToChat(user, conversation: conversation)
            }
        }
    }
    
    func goToChat(_ selectedUser: PFUser, conversation: Conversation?) {
        guard let currentUser = PFUser.current(), let currentUserId = currentUser.objectId, let selectedUserId = selectedUser.objectId, let conversation = conversation else {
            print("goToChat failed")
            return
        }
        
        QBUserService.getQBUUserFor(selectedUser) { [weak self] user in
            guard let user = user else {
                print("no user")
                return
            }
            SessionService.sharedInstance.startChatWithUser(user, conversation, completion: { (success, dialog) in
                guard success else {
                    print("Could not start chat")
                    self?.simpleAlert("Could not start chat", defaultMessage: "There was an error starting a chat with this person", error: nil, completion: nil)
                    return
                }
                
                if let chatNavigationVC = UIStoryboard(name: "Chat", bundle: nil).instantiateViewController(withIdentifier: "ChatNavigationViewController") as? UINavigationController,
                    let chatVC = chatNavigationVC.viewControllers[0] as? ChatViewController {
                    chatVC.dialog = dialog
                    chatVC.conversation = conversation
                    self?.present(chatNavigationVC, animated: true, completion: {
                        if let user = PFUser.current(), let userId = user.objectId, let unread = conversation.unreadIds as? [String], let index = unread.index(of: userId) {
                            conversation.unreadIds?.remove(at: index)
                            conversation.saveEventually({ (success, error) in
                                NotificationCenter.default.post(name: NSNotification.Name("conversations:updated"), object: nil, userInfo: nil)
                            })
                        }
                    })
                }
            })
        }
    }
    

}

extension ChatListViewController: ConversationCellDelegate {
    func didGetUser(user: User, forConversation conversation: Conversation) {
        users[conversation] = user
    }
}
