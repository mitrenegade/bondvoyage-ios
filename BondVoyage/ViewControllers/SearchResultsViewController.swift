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

enum filterButtonTag: Int {
    case genderTag = 1 // Tags are set in storyboard
    case groupSizeTag = 2
    case ageRangeTag = 3
}

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
    @IBOutlet weak var filterViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filterView: UIView!
    var users: [PFUser]?
    var currentFilterOpenTag: filterButtonTag?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.filterViewHeightConstraint.constant = 0
    }

    @IBAction func filterGenderButtonPressed(sender: UIButton) {
        self.toggleFilterViewForHeight(filterButtonTag: sender.tag, height: 44)
        self.currentFilterOpenTag = filterButtonTag.genderTag
    }

    func toggleFilterViewForHeight(filterButtonTag tag: Int, height: CGFloat) {
        let filterViewIsShowing = self.filterView.frame.height != 0

        if tag == self.currentFilterOpenTag?.rawValue {
            if filterViewIsShowing {
                // the user wants to close what is already open
                self.closeFilterView(nil)
                return
            }
        }

        // else the user wants to open a different one filter.
        // if a filter is currently showing, you want to close it.
        if filterViewIsShowing {
            self.closeFilterView({ () -> Void in
                self.openFilterView(height)
            })
        }
        else {
            self.openFilterView(height)
        }
    }

    func openFilterView(height: CGFloat) {
        self.filterViewHeightConstraint.constant = height
        UIView.animateWithDuration(0.5) { () -> Void in
            self.view.layoutIfNeeded()
        }
        print("filter view open")
    }
    
    func closeFilterView(completion: (() -> Void)?) {
        self.filterViewHeightConstraint.constant = 0
        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.view.layoutIfNeeded()
            },
            completion: { (Bool) -> Void in
                print("filter view closed")
                if completion != nil {
                    completion!()
                }
            }
        )
    }

    //TODO: consolidate these filter buttons into one action
    @IBAction func filterAgeRangeButtonPressed(sender: UIButton) {
        self.toggleFilterViewForHeight(filterButtonTag: sender.tag, height: 60)
        self.currentFilterOpenTag = filterButtonTag.ageRangeTag
    }

    @IBAction func filterGroupSizeButtonPressed(sender: UIButton) {
        self.toggleFilterViewForHeight(filterButtonTag: sender.tag, height: 100)
        self.currentFilterOpenTag = filterButtonTag.groupSizeTag
    }


    // MARK: - UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

    }

    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kSearchResultCellIdentifier)! as! ActivitySearchResultCell
        cell.adjustTableViewCellSeparatorInsets(cell)
//        cell.configureCellForSearchResult(users![indexPath.row])
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let numUsers: Int = users?.count {
//            return numUsers
//        }
//        else {
//            print("No users found")
//            return 0
//        }
        return 5
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
