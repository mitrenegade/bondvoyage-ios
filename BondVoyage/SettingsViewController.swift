
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

        let imageView: UIImageView = UIImageView(image: UIImage(named: "logo-plain")!)
        imageView.frame = CGRectMake(0, 0, 150, 44)
        imageView.contentMode = .ScaleAspectFit
        imageView.backgroundColor = Constants.lightBlueColor()
        imageView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, 22)
        self.navigationController!.navigationBar.addSubview(imageView)
        self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let row: Int = indexPath.row
        
        // Configure the cell...
        if row == 0 {
            // edit profile
            cell.textLabel?.text = "Profile"
        }
        else if row == 1 {
            // edit search parameters
            cell.textLabel?.text = "Search preferences"
        }
        else if row == 2 {
            // logout
            cell.textLabel?.text = "Log out"
        }

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row: Int = indexPath.row
        if row == 0 {
            self.goToProfile()
        }
        else if row == 1 {
            self.goToSearchPreferences()
        }
        else if row == 2 {
            PFUser.logOut()
            NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
        }
    }
    
    func goToSearchPreferences() {
        let controller: SearchPreferencesViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SearchPreferencesViewController") as! SearchPreferencesViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }

    func goToProfile() {
        let controller: ProfileViewController = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
