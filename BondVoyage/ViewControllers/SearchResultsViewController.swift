//
//  SearchResultsViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/23/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit
import Parse
import AsyncImageView

protocol SearchResultsDelegate {
    func showUserDetails()
}

let date = NSDate()
let calendar = NSCalendar.currentCalendar()
let components = calendar.components([.Day , .Month , .Year], fromDate: date)

let kSearchResultCellIdentifier = "searchResultCell"

class UserSearchResultCell: UITableViewCell {

    @IBOutlet weak var profileImage: AsyncImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var genderAndAgeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!

    func configureCellForUser(user: PFUser) {
        let currentYear = components.year
        let age = currentYear - (user.valueForKey("birthYear") as! Int)

        var name: String? = user.valueForKey("firstName") as? String
        if name == nil {
            name = user.valueForKey("lastName") as? String
        }
        if name == nil {
            name = user.username
        }
        self.usernameLabel.text = name
        self.genderAndAgeLabel.text = "\(user.valueForKey("gender")!), age: \(age)"

        var info: String? = nil
        if let interests: [String] = user.valueForKey("interests") as? [String] {
            if interests.count > 0 {
                info = "Likes: \(interests[0])"
                if interests.count > 1 {
                    for var i=1; i < interests.count; i++ {
                        info = "\(info!), \(interests[i])"
                    }
                }
            }
        }
        self.infoLabel.text = info

        if let photoURL: String = user.valueForKey("photoUrl") as? String {
            self.profileImage.imageURL = NSURL(string: photoURL)
        }
        else {
            self.profileImage.image = UIImage(named: "profile-icon")
        }

        self.profileImage.layer.cornerRadius = self.profileImage.frame.size.width / 2
        self.profileImage.layer.borderColor = Constants.blueColor().CGColor
        self.profileImage.layer.borderWidth = 2
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

    var delegate: SearchResultsDelegate?

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
            self.ageRangeFilterView.configure(RANGE_AGE_MIN, maxAge: RANGE_AGE_MAX, lower: RANGE_AGE_MIN, upper: RANGE_AGE_MAX)
            self.groupSizeFilterView.configure(RANGE_GROUP_MIN, maxSize: RANGE_GROUP_MAX, lower: RANGE_GROUP_MIN, upper: RANGE_GROUP_MAX)
            self.genderFilterView.configure(GenderPrefs.Male)
            self.configuredFilters = true
        }

        self.loadPreferences()
    }

    // MARK: - Preferences
    func loadPreferences() {
        if PFUser.currentUser() != nil {
            if let prefObject: PFObject = PFUser.currentUser()!.objectForKey("preferences") as? PFObject {
                // load from local store
                prefObject.fetchFromLocalDatastoreInBackgroundWithBlock({ (object, error) -> Void in
                    if error == nil {
                        self.refresh()
                    }
                    else {
                        // load from web
                        prefObject.fetchInBackgroundWithBlock({ (object, error) -> Void in
                            if error == nil {
                                self.refresh()
                            }
                        })
                    }
                })
            }
        }
    }

    func refresh() {
        if let prefObject: PFObject = PFUser.currentUser()!.objectForKey("preferences") as? PFObject {

            // gender preferences
            if let genderPrefs: [String] = prefObject.objectForKey("gender") as? [String] {
                if genderPrefs.count == 1 {
                    self.genderFilterView.setSliderSelection(genderPrefs[0])
                }
                else {
                    self.genderFilterView.setSliderSelection(GenderPrefs.All.rawValue)
                }
            }

            // age preferences
            var ageMin = Int(self.ageRangeFilterView.rangeSlider!.minimumValue)
            var ageMax = Int(self.ageRangeFilterView.rangeSlider!.maximumValue)
            if let lower: Int = prefObject.objectForKey("ageMin") as? Int {
                ageMin = lower
            }
            if let upper: Int = prefObject.objectForKey("ageMax") as? Int {
                ageMax = upper
            }
            self.ageRangeFilterView.setSliderValues(lower: ageMin, upper: ageMax)

            // group size preferences
            var groupMin = Int(self.groupSizeFilterView.rangeSlider!.minimumValue)
            var groupMax = Int(self.groupSizeFilterView.rangeSlider!.maximumValue)
            if let lower: Int = prefObject.objectForKey("groupMin") as? Int {
                groupMin = lower
            }
            if let upper: Int = prefObject.objectForKey("groupMax") as? Int {
                groupMax = upper
            }
            self.groupSizeFilterView.setSliderValues(lower: groupMin, upper: groupMax)
        }
    }

    func enableButtons(enabled: Bool) {
        for button: UIButton in [self.genderButton, self.ageRangeButton, self.groupSizeButton] {
            button.enabled = enabled
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
        self.enableButtons(false)

        // If there is no filter open at all, simply open filterToOpen.

        if self.currentFilterView == nil {
            self.openFilterViewWithCompletion(filterToOpen, completion: { () -> Void in
                self.enableButtons(true)
            })
        }
        // If the filter to open is already open, close the current filter view.
        else if self.currentFilterView == filterToOpen {
            self.closeFilterViewWithCompletion({ () -> Void in
                self.enableButtons(true)
            })
        }
        // If there is a filter opened already, close it, and open the other one.
        else if self.currentFilterView != filterToOpen {
            self.closeFilterViewWithCompletion({ () -> Void in
                self.openFilterViewWithCompletion(filterToOpen, completion: { () -> Void in
                    self.enableButtons(true)
                })
            })
        }
    }

    func openFilterViewWithCompletion(filterToOpen: BaseFilterView, completion: (() -> Void)?) {
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
                if completion != nil {
                    completion!()
                }
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
        let user = users![indexPath.row]
        let hereAndNowVC = self.parentViewController as! HereAndNowViewController
        hereAndNowVC.selectedUser = user
        self.delegate?.showUserDetails()
    }

    // MARK: - UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kSearchResultCellIdentifier)! as! UserSearchResultCell
        cell.adjustTableViewCellSeparatorInsets(cell)
        if users != nil {
            cell.configureCellForUser(users![indexPath.row])
        }
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
}
