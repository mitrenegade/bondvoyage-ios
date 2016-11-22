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

class ChatListViewController: UIViewController { //, UITableViewDataSource, UITableViewDelegate {

//    @IBOutlet weak var tableView: UITableView!
    // live query for Parse objects
    let liveQueryClient = ParseLiveQuery.Client()
    var subscription: Subscription<Conversation>?
    var isSubscribed: Bool = false

    var conversations: [Conversation]?

    
    override func viewDidLoad() {
        super.viewDidLoad()

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
