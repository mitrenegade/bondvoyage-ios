//
//  SearchResultsViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/23/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit
import Parse

let kSearchResultCellIdentifier = "searchResultCell"

class ActivitySearchResultCell: UITableViewCell {

    @IBOutlet weak var searchResultTitleLabel: UILabel!
    @IBOutlet weak var peopleCollectionView: UICollectionView!

    func configureCellForSearchResult(person: PFUser) {
        self.searchResultTitleLabel.text = person.username
        //TODO: give this cell a better name
        //TODO: configure the label
        //TODO: configure collection view
    }
}

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var users: [PFUser]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.users = [PFUser]() //Not sure if the array needs to be initialized
    }

    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kSearchResultCellIdentifier)!
        cell.adjustTableViewCellSeparatorInsets(cell)
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numUsers: Int = users?.count {
            return numUsers
        }
        else {
            print("No users found")
            return 0
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
