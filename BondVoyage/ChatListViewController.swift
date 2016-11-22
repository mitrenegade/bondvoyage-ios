//
//  ChatListViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 11/21/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController { //, UITableViewDataSource, UITableViewDelegate {

//    @IBOutlet weak var tableView: UITableView!

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
