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

    var currentFilterView: BaseFilterView?
    var configuredFilters: Bool = false

    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var groupSizeButton: UIButton!
    @IBOutlet weak var ageRangeButton: UIButton!

    @IBOutlet weak var genderFilterView: GenderFilterView!
    @IBOutlet weak var groupSizeFilterView: GroupSizeFilterView!
    @IBOutlet weak var ageRangeFilterView: AgeRangeFilterView!
    
    @IBOutlet weak var genderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupSizeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ageRangeViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewTopSpacingConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize filter view heights to 0.
        self.genderViewHeightConstraint.constant = 0
        self.groupSizeViewHeightConstraint.constant = 0
        self.ageRangeViewHeightConstraint.constant = 0
        self.tableViewTopSpacingConstraint.constant = 0
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if (!self.configuredFilters) {
            self.ageRangeFilterView.configure(16, maxAge: 85, lower: 16, upper: 85)
            self.groupSizeFilterView.configure(1, maxSize: 10, lower: 1, upper: 10)
            self.genderFilterView.configure(Gender.Male.rawValue)
            self.configuredFilters = true
        }
    }
    
    // MARK: Filter View Methods

    @IBAction func filterButtonPressed(sender: UIButton) {
        var filterToOpen: BaseFilterView?
        switch sender {
        case self.genderButton:
            filterToOpen = self.genderFilterView
            break
        case self.groupSizeButton:
            filterToOpen = self.groupSizeFilterView
            break
        case self.ageRangeButton:
            filterToOpen = self.ageRangeFilterView
            break
        default:
            return // Should not reach here
        }
        self.toggleFilterView(filterToOpen!)
    }

    func toggleFilterView(filterToOpen: BaseFilterView) {
        // If there is no filter open at all, simply open filterToOpen.
        if self.currentFilterView == nil {
            self.openFilterView(filterToOpen)
        }
        // If the filter to open is already open, close the current filter view.
        else if self.currentFilterView == filterToOpen {
            self.closeFilterViewWithCompletion(nil)
        }
        // If there is a filter opened already, close it, and open the other one.
        else if self.currentFilterView != filterToOpen {
            self.closeFilterViewWithCompletion({ () -> Void in
                self.openFilterView(filterToOpen)
            })
        }
    }

    func openFilterView(filterToOpen: BaseFilterView) {
        let height = filterToOpen.openHeight()
        self.heightConstraint(filterToOpen).constant = height
        self.tableViewTopSpacingConstraint.constant = height

        UIView.animateWithDuration(0.5,
            animations: { () -> Void in
                self.view.layoutIfNeeded()
            },
            completion: { (Bool) -> Void in
                self.currentFilterView = filterToOpen
                print("Filter view \(self.currentFilterView) opened")
            }
        )
    }

    func closeFilterViewWithCompletion(completion: (() -> Void)?) {
        if self.currentFilterView != nil {
            self.heightConstraint(self.currentFilterView!).constant = 0
            self.tableViewTopSpacingConstraint.constant = 0
            UIView.animateWithDuration(0.5,
                animations: { () -> Void in
                    self.view.layoutIfNeeded()
                },
                completion: { (Bool) -> Void in
                    print("Filter view \(self.currentFilterView) was closed")
                    self.currentFilterView = nil
                    if completion != nil {
                        completion!()
                    }
                }
            )
        }
    }

    //Helper method to get the height constraint of the filterView that is to be toggled
    func heightConstraint(filterView: BaseFilterView) -> NSLayoutConstraint {
        switch filterView {
        case self.genderFilterView:
            return self.genderViewHeightConstraint
        case self.groupSizeFilterView:
            return self.groupSizeViewHeightConstraint
        default: // case self.ageRangeFilterView:
            return self.ageRangeViewHeightConstraint
        }
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
