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
    func didSelectCategory(category: String?)
}
class SearchCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var expanded: [Bool] = [Bool]()
    
    weak var delegate: SearchCategoriesDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.closeCategories()

        if PFUser.currentUser() == nil {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Log In", style: .Done, target: self, action: "goToLogin")
        }
        else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: .Done, target: self, action: "goToSettings")
        }
    }
    
    func closeCategories() {
        for _ in CategoryFactory.categories() {
            expanded.append(false)
        }
        self.tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell")!
            cell.textLabel!.text = CategoryFactory.categories()[indexPath.section]
            cell.backgroundColor = UIColor.clearColor()
            return cell
        }
        let cell = tableView.dequeueReusableCellWithIdentifier("SubcategoryCell")!
        let category = CategoryFactory.categories()[indexPath.section]
        let subs = CategoryFactory.subCategories(category)
        let index = indexPath.row - 1
        cell.backgroundColor = UIColor.whiteColor()
        cell.textLabel!.text = subs[index]
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return CategoryFactory.categories().count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.expanded[section] {
            let category: String = CategoryFactory.categories()[section]
            return CategoryFactory.subCategories(category).count + 1
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
        }
        else {
            let category = CategoryFactory.categories()[indexPath.section]
            let subs = CategoryFactory.subCategories(category)
            let index = indexPath.row - 1
            let subcategory: String = subs[index]
            
            self.selectCategory(subcategory)
        }
    }
    
    func selectCategory(subcategory: String) {
        if self.delegate != nil {
            // this controller used as a filter
            self.delegate?.didSelectCategory(subcategory)
        }
        else {
            self.performSegueWithIdentifier("GoToNewActivity", sender: subcategory)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToNewActivity" {
            let controller: NewActivityViewController = segue.destinationViewController as! NewActivityViewController
            controller.selectedCategory = sender as? String
        }
    }
}
