//
//  SearchCategoriesViewController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/20/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import AsyncImageView
import Parse

let kNearbyEventCellIdentifier = "nearbyEventCell"

protocol SearchCategoriesDelegate: class {
    func didSelectCategory(subcategory: String?, category: String?)
}
class SearchCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var expanded: [Bool] = [Bool]()
    
    weak var delegate: SearchCategoriesDelegate?
    
    var newSubcategory: String?
    var newCategory: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // configure title bar
        if self.navigationController != nil {
            let imageView: UIImageView = UIImageView(image: UIImage(named: "logo-plain")!)
            imageView.frame = CGRectMake(0, 0, 150, 44)
            imageView.contentMode = .ScaleAspectFit
            imageView.backgroundColor = Constants.lightBlueColor()
            imageView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, 22)
            self.navigationController!.navigationBar.addSubview(imageView)
            self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.closeCategories()
    }
    
    func closeCategories() {
        for _ in CategoryFactory.categoryStrings() {
            expanded.append(false)
        }
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell")!
            cell.textLabel!.text = CategoryFactory.categoryStrings()[indexPath.section]
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SubcategoryCell")!
        let category = CategoryFactory.categoryStrings()[indexPath.section]
        if category == "Other" {
            cell.textLabel!.text = "Other"
        }
        else {
            if indexPath.row == 1 {
                cell.textLabel!.text = "Any"
            }
            else {
                let subs = CategoryFactory.subCategoryStrings(category)
                let index = indexPath.row - 2
                cell.textLabel!.text = subs[index]
            }
        }
        
        cell.backgroundColor = UIColor.whiteColor()
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return CategoryFactory.categoryStrings().count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.expanded[section] {
            let category: String = CategoryFactory.categoryStrings()[section]
            if category == "Other" {
                return CategoryFactory.subCategoryStrings(category).count + 1
            }
            return CategoryFactory.subCategoryStrings(category).count + 2 // including Other
        }
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == 0 {
            for var i=0; i<expanded.count; i++ {
                if i != indexPath.section {
                    expanded[i] = false
                }
            }
            expanded[indexPath.section] = !expanded[indexPath.section]
            self.tableView.reloadData()
            if expanded[indexPath.section] {
                self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            }
        }
        else {
            let category = CategoryFactory.categoryStrings()[indexPath.section]
            if category == "Other" {
                self.selectCategory("Other", category: "Other")
            }
            else {
                if indexPath.row == 1 {
                    self.selectCategory(nil, category: category)
                }
                else {
                    let subs = CategoryFactory.subCategoryStrings(category)
                    let index = indexPath.row - 2
                    let subcategory: String = subs[index]
                    
                    self.selectCategory(subcategory, category: category)
                }
            }
        }
    }
    
    func selectCategory(subcategory: String?, category: String) {
        if self.delegate != nil {
            // this controller used as a filter
            self.delegate?.didSelectCategory(subcategory, category: category)
        }
        else {
            self.newSubcategory = subcategory
            self.newCategory = category
            self.performSegueWithIdentifier("GoToNewActivity", sender: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToNewActivity" {
            let controller: NewActivityViewController = segue.destinationViewController as! NewActivityViewController
            if self.newSubcategory != nil {
                controller.selectedCategories = [self.newSubcategory!]
            }
            else if self.newCategory != nil {
                controller.selectedCategories = CategoryFactory.subCategoryStrings(self.newCategory!)
            }
        }
    }
}
