//
//  SearchPreferencesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/12/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

protocol SearchPreferencesDelegate: class {
    func didUpdateSearchPreferences()
}

class SearchPreferencesViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var ageFilterView: AgeRangeFilterView!
    @IBOutlet weak var groupFilterView: GroupSizeFilterView!
    @IBOutlet weak var distanceFilterView: DistanceFilterView!
    
    weak var delegate: SearchPreferencesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear Filters", style: .Plain, target: self, action: "clearFilters")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Apply Filters", style: .Plain, target: self, action: "saveFilters")
        
        self.ageFilterView.configure(RANGE_AGE_MIN, maxAge: RANGE_AGE_MAX, lower: RANGE_AGE_MIN, upper: RANGE_AGE_MAX)
        self.groupFilterView.configure(RANGE_GROUP_MIN, maxSize: RANGE_GROUP_MAX, lower: RANGE_GROUP_MIN, upper: RANGE_GROUP_MAX)
        self.distanceFilterView.configure(RANGE_DISTANCE_MAX, upper: RANGE_DISTANCE_MAX)

        // load preferences
        if PFUser.currentUser() == nil {
            self.simpleAlert("Error loading user", message: "You are not logged in. Please log in and try again.", completion: { () -> Void in
                self.close()
            })
        }
        else {
            if let prefObject: PFObject = PFUser.currentUser()!.objectForKey("preferences") as? PFObject {
                // load from local store
                prefObject.fetchFromLocalDatastoreInBackgroundWithBlock({ (object, error) -> Void in
                    if error == nil {
                        self.refresh()
                    }
                    else {
                        // load from web
                        prefObject.fetchInBackgroundWithBlock({ (object, error) -> Void in
                            if error != nil {
                                self.simpleAlert("Error loading preferences", message: "There was an error loading your search preferences. Please try logging in again.", completion: { () -> Void in
                                    self.close()
                                })
                            }
                            else {
                                self.refresh()
                            }
                        })
                    }
                })
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func clearFilters() {
        self.ageFilterView.configure(RANGE_AGE_MIN, maxAge: RANGE_AGE_MAX, lower: RANGE_AGE_MIN, upper: RANGE_AGE_MAX)
        self.groupFilterView.configure(RANGE_GROUP_MIN, maxSize: RANGE_GROUP_MAX, lower: RANGE_GROUP_MIN, upper: RANGE_GROUP_MAX)
        self.distanceFilterView.configure(RANGE_DISTANCE_MAX, upper: RANGE_DISTANCE_MAX)
        
        self.saveFilters()
    }
    
    func saveFilters() {
        var prefObject: PFObject? = PFUser.currentUser()!.objectForKey("preferences") as? PFObject
        if prefObject == nil {
            prefObject = PFObject(className: "SearchPreference")
        }
        let ageMin = Int(self.ageFilterView.rangeSlider!.lowerValue)
        let ageMax = Int(self.ageFilterView.rangeSlider!.upperValue)
        let groupMin = Int(self.groupFilterView.rangeSlider!.lowerValue)
        let groupMax = Int(self.groupFilterView.rangeSlider!.upperValue)
        var distMax = Double(self.distanceFilterView.rangeSlider!.upperValue)
        
        if self.distanceFilterView.rangeSlider!.upperValue > 50 && self.distanceFilterView.rangeSlider!.upperValue <= 52 {
            distMax = 100
        }
        else if self.distanceFilterView.rangeSlider!.upperValue > 52 {
            distMax = 500
        }

        
        prefObject!.setValue(ageMin, forKey: "ageMin")
        prefObject!.setValue(ageMax, forKey: "ageMax")
        prefObject!.setValue(groupMin, forKey: "groupMin")
        prefObject!.setValue(groupMax, forKey: "groupMax")
        prefObject!.setValue(distMax, forKey: "distanceMax")
        prefObject!.setValue(PFUser.currentUser()!, forKey: "user")
        prefObject!.pinInBackground()
        
        prefObject!.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                PFUser.currentUser()!.setObject(prefObject!, forKey: "preferences")
                PFUser.currentUser()!.saveInBackground()
            }
        })
        
        if self.delegate != nil {
            self.delegate!.didUpdateSearchPreferences()
        }
        self.close()
    }
    
    func refresh() {
        if let prefObject: PFObject = PFUser.currentUser()!.objectForKey("preferences") as? PFObject {

            // age preferences
            var ageMin = Int(self.ageFilterView.rangeSlider!.minimumValue)
            var ageMax = Int(self.ageFilterView.rangeSlider!.maximumValue)
            if let lower: Int = prefObject.objectForKey("ageMin") as? Int {
                ageMin = lower
            }
            if let upper: Int = prefObject.objectForKey("ageMax") as? Int {
                ageMax = upper
            }
            self.ageFilterView.setSliderValues(lower: ageMin, upper: ageMax)
            
            // group size preferences
            var groupMin = Int(self.groupFilterView.rangeSlider!.minimumValue)
            var groupMax = Int(self.groupFilterView.rangeSlider!.maximumValue)
            if let lower: Int = prefObject.objectForKey("groupMin") as? Int {
                groupMin = lower
            }
            if let upper: Int = prefObject.objectForKey("groupMax") as? Int {
                groupMax = upper
            }
            self.groupFilterView.setSliderValues(lower: groupMin, upper: groupMax)

            // distance preferences
            var distMax = Int(self.distanceFilterView.rangeSlider!.maximumValue)
            if let upper: Int = prefObject.objectForKey("distanceMax") as? Int {
                distMax = upper
            }
            self.distanceFilterView.setSliderValues(lower: -100, upper: distMax)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
