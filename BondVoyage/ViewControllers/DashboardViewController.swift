//
//  DashboardViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/11/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit

let kCellIdentifier:String = "activityCell" //TODO: this might be a NearbyEventCell, depending on whether we keep the "dashboard" view

class DashboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier)!
        cell.adjustTableViewCellSeparatorInsets(cell)
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

}
