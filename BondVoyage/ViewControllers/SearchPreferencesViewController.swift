//
//  SearchPreferencesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/12/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class SearchPreferencesViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var genderFilterView: GenderFilterView!
    @IBOutlet weak var ageFilterView: AgeRangeFilterView!
    @IBOutlet weak var groupFilterView: GroupSizeFilterView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "close")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "save")
        
        // load preferences
        if PFUser.currentUser() == nil {
            self.simpleAlert("Error loading user", message: "You are not logged in. Please log in and try again.", completion: { () -> Void in
                self.close()
            })
        }
        else {
            if let prefObject: PFObject = PFUser.currentUser()!.objectForKey("preferences") as? PFObject {
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
            self.refresh()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func save() {
        var prefObject: PFObject? = PFUser.currentUser()!.objectForKey("preferences") as? PFObject
        if prefObject == nil {
            prefObject = PFObject(className: "SearchPreference")
        }
        let gender = Int(self.genderFilterView.slider!.currentValue)
        let ageMin = Int(self.ageFilterView.rangeSlider!.minimumValue)
        let ageMax = Int(self.ageFilterView.rangeSlider!.maximumValue)
        let groupMin = Int(self.groupFilterView.rangeSlider!.minimumValue)
        let groupMax = Int(self.groupFilterView.rangeSlider!.maximumValue)
        
        prefObject!.setValue(gender, forKey: "gender")
        prefObject!.setValue(ageMin, forKey: "ageMin")
        prefObject!.setValue(ageMax, forKey: "ageMax")
        prefObject!.setValue(groupMin, forKey: "groupMin")
        prefObject!.setValue(groupMax, forKey: "groupMax")
        prefObject!.setValue(PFUser.currentUser()!, forKey: "user")
        prefObject!.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success {
                PFUser.currentUser()!.setObject(prefObject!, forKey: "preferences")
                PFUser.currentUser()!.saveInBackground()
            }
        })
        
        self.close()
    }
    
    func refresh() {
        if let prefObject: PFObject = PFUser.currentUser()!.objectForKey("preferences") as? PFObject {

            // gender preferences
            if let gender: Int = prefObject.objectForKey("gender") as? Int {
                self.genderFilterView.slider!.currentValue = Double(gender)
            }
            
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
