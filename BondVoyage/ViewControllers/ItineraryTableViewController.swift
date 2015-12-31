//
//  ItineraryTableViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/12/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit

enum ItineraryRowType: Int {
    case Interests
    case Chat
    case Location
}

let kInterestsCellIdentifier = "interestsCell"
let kChatCellIdentifier = "goToChatCell"
let kViewLocationCellIdentifier = "viewLocationInMapsCell"

class ItineraryTableViewController: UITableViewController {

    @IBOutlet weak var viewLocationInMapsCell: UITableViewCell!
    @IBOutlet weak var goToChatCell: UITableViewCell!
    @IBOutlet weak var interestsCell: UITableViewCell!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        let rowType: ItineraryRowType = ItineraryRowType(rawValue: indexPath.row)!

        switch (rowType) {
        case .Interests:
            cell = self.interestsCell
            break
        case .Chat:
            cell = self.goToChatCell
            break
        case .Location:
            cell = self.viewLocationInMapsCell
            break
        }
        cell.adjustTableViewCellSeparatorInsets(cell)
        return cell
    }

    // MARK: - UITableViewDelegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: set up detail page
    }
}
