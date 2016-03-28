//
//  WhenAndWhereViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 3/28/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class WhenAndWhereViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var viewWhere: UIView!
    @IBOutlet weak var viewWhen: UIView!
    @IBOutlet weak var viewAboutMe: UIView!
    @IBOutlet weak var viewWho: UIView!
    @IBOutlet weak var viewAges: UIView!
    
    @IBOutlet weak var inputWhere, inputWhen, inputAboutMe: UITextField!
    
    @IBOutlet weak var tableViewWho: UITableView!
    @IBOutlet weak var constraintTableViewHeight: NSLayoutConstraint!
    var selectedTypes: [Bool] = [false, false, false, false]
    
    @IBOutlet weak var ageFilterView: AgeRangeFilterView!

    var pickerWhere: UIPickerView = UIPickerView()
    var pickerWhen: UIPickerView = UIPickerView()
    var pickerMe: UIPickerView = UIPickerView()
    
    let ROW_HEIGHT: CGFloat = 44
    let PERSON_TYPES = ["New to the city", "Local to the city", "On leisure", "Traveling for business"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        for view: UIView in [viewWhere, viewWhen, viewAboutMe, viewWho, viewAges] {
            view.backgroundColor = UIColor.clearColor()
        }

        pickerWhere.delegate = self
        pickerWhen.delegate = self
        pickerMe.delegate = self
        
        self.ageFilterView.configure(RANGE_AGE_MIN, maxAge: RANGE_AGE_MAX, lower: RANGE_AGE_MIN, upper: RANGE_AGE_MAX)
        
        self.constraintTableViewHeight.constant = ROW_HEIGHT * CGFloat(PERSON_TYPES.count)
    }
    
    // MARK: UITableViewDatasource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PERSON_TYPES.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ROW_HEIGHT
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonTypeCell", forIndexPath: indexPath)
        cell.textLabel?.font = UIFont(name: "Avenir-Next", size: 15)
        cell.textLabel?.text = PERSON_TYPES[indexPath.row]
        
        if self.selectedTypes[indexPath.row] {
            cell.backgroundColor = UIColor.greenColor()
        }
        else {
            cell.backgroundColor = UIColor.redColor()
        }
        return cell
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableViewWho.deselectRowAtIndexPath(indexPath, animated: false)
        selectedTypes[indexPath.row] = !selectedTypes[indexPath.row]
        self.tableViewWho.reloadData()
    }

    // MARK: - UIPickerViewDataSource
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.pickerWhere || pickerView == self.pickerWhen {
            return 1
        }
        else if pickerView == self.pickerMe {
            return PERSON_TYPES.count
        }
        return 0
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.pickerWhere {
            return "Boston"
        }
        if pickerView == self.pickerWhen {
            return "Now"
        }
        return PERSON_TYPES[row]
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Row selected: \(row)")
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
