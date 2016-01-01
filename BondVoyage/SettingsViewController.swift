
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
        return 4
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)        
        let row: Int = indexPath.row
        
        // Configure the cell...
        if row == 0 {
            // edit profile
            cell.textLabel?.text = "Profile"
        }
        else if row == 1 {
            // interest cloud
            cell.textLabel?.text = "Interests"
        }
        else if row == 2 {
            // edit search parameters
            cell.textLabel?.text = "Search preferences"
        }
        else if row == 3 {
            // logout
            cell.textLabel?.text = "Log out"
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row: Int = indexPath.row
        if row == 0 {
            self.performSegueWithIdentifier("toProfile", sender: nil)
        }
        else if row == 1 {
            self.performSegueWithIdentifier("toInterests", sender: nil)
        }
        else if row == 2 {
            self.simpleAlert("Default preferences editing coming soon", message: nil)
        }
        else if row == 3 {
            PFUser.logOut()
            self.close()
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
