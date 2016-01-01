
//
//  SettingsViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/1/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .Plain, target: self, action: "close")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont(name: "Lato-Regular", size: 15.0)
        
        let row: Int = indexPath.row
        
        // Configure the cell...
        if row == 0 {
            // edit profile
            cell.textLabel?.text = "Profile"
        }
        else if row == 1 {
            // edit search parameters
            cell.textLabel?.text = "Default preferences"
        }
        else if row == 2 {
            // logout
            cell.textLabel?.text = "Log out"
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row: Int = indexPath.row
        if row == 0 {
            self.performSegueWithIdentifier("toProfile", sender: nil)
        }
        else if row == 1 {
            self.simpleAlert("Default preferences editing coming soon", message: nil)
        }
        else if row == 2 {
            PFUser.logOut()
            self.close()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toProfile" {
            let controller: SignUpViewController = segue.destinationViewController as! SignUpViewController
            controller.type = .ProfileOnly
        }
    }

}
