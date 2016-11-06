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
            
            self.setLeftProfileButton()
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
        return 140
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let category = CATEGORIES[indexPath.row]
        self.selectCategory(category)
        
        // TEST: device push
        /*
        let params = ["channel": "channelGlobal", "message": "test message"]
        PFCloud.callFunctionInBackground("sendPushFromDevice", withParameters: params) { (results, error) in
            print("results \(results) error \(error)")
        }
        */
    }
    
    func selectCategory(category: CATEGORY) {
        self.newCategory = category
        
        self.requestActivities()
    }
    
    func requestActivities() {
        let cat: [String] = [self.newCategory!.rawValue]
        
        ActivityRequest.queryActivities(nil, categories: cat) { (results, error) -> Void in
            self.navigationItem.rightBarButtonItem?.enabled = true
            if results != nil {
                if results!.count > 0 {
                    print("results \(results)")
                }
                else {
                    // no results, no error
                    var message = "There is no one interested in \(CategoryFactory.categoryReadableString(self.newCategory!)) near you."
                    if PFUser.currentUser() != nil {
                        message = "\(message) For the next hour, other people will be able to search for you and invite you to bond."
                    }
                    
                    self.simpleAlert("No activities nearby", message: message, completion: { () -> Void in
                        self.navigationController?.popToRootViewControllerAnimated(true)
                    })
                }
            }
            else {
                if error != nil && error!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                        UserService.logout()
                    })
                    return
                }
                let message = "There was a problem loading matches. Please try again"
                self.simpleAlert("Could not select category", defaultMessage: message, error: error)
            }
        }
    }
    

}
