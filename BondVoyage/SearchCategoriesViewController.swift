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

protocol SearchCategoriesDelegate: class {
    func didSelectCategory(category: CATEGORY?)
}
class SearchCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: SearchCategoriesDelegate?
    
    var newCategory: CATEGORY?
    
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
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as! CategoryCell
        let category: CATEGORY = CATEGORIES[indexPath.row]
        cell.titleLabel!.text = CategoryFactory.categoryReadableString(category)
        cell.backgroundColor = UIColor.clearColor()
        cell.bgImage.image = CategoryFactory.categoryBgImage(category.rawValue)
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CATEGORIES.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 180
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let category = CATEGORIES[indexPath.section]
        self.selectCategory(category)
    }
    
    func selectCategory(category: CATEGORY) {
        self.newCategory = category
        self.performSegueWithIdentifier("GoToNewActivity", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "GoToNewActivity" {
            let controller: NewActivityViewController = segue.destinationViewController as! NewActivityViewController
            if self.newCategory != nil {
                controller.selectedCategories = [self.newCategory!.rawValue]
            }
        }
    }
}
