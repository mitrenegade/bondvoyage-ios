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

class SearchCategoriesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatesViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    var datesController: DatesViewController?
    
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
        
        self.showDateSelector()
    }
    
    // MARK: - Date selector
    func showDateSelector() {
        guard let controller = UIStoryboard(name: "Bobby", bundle: nil).instantiateViewControllerWithIdentifier("DatesViewController") as? DatesViewController else {
            return
        }
        
        self.datesController = controller
        self.datesController?.delegate = self
        
        let topOffset: CGFloat = 40 // keep the "I'm in the mood for" exposed
        var frame = self.view.frame
        frame.origin.y = self.view.frame.size.height
        frame.size.height -= topOffset
        controller.view.frame = frame
        controller.willMoveToParentViewController(self)
        self.addChildViewController(controller)
        self.view.addSubview(controller.view)
        frame.origin.y = topOffset
        UIView.animateWithDuration(0.25, animations: {
            controller.view.frame = frame
        }) { (success) in
            controller.didMoveToParentViewController(self)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideDateSelector))
        self.headerView.addGestureRecognizer(tap)
    }
    
    func didSelectDates(startDate: NSDate?, endDate: NSDate?) {
        self.hideDateSelector()
        
        print("dates selected: \(startDate) to \(endDate)")
        self.requestActivities()
    }
    
    func hideDateSelector() {
        guard let controller = self.datesController else { return }
        
        var frame = controller.view.frame
        frame.origin.y = frame.size.height
        controller.willMoveToParentViewController(nil)
        UIView.animateWithDuration(0.25, animations: {
            controller.view.frame = frame
        }) { (success) in
            controller.view.removeFromSuperview()
            controller.removeFromParentViewController()
            self.datesController = nil
        }
        if let recognizers = self.headerView.gestureRecognizers {
            for recognizer in recognizers {
                self.headerView.removeGestureRecognizer(recognizer)
            }
        }
    }
    
    // MARK: - Activities
    func requestActivities() {
        guard let category = self.newCategory else { return }
        let interests = [CategoryFactory.interestsForCategory(category)]
        UserRequest.userQuery(interests) { (results, error) in
            self.navigationItem.rightBarButtonItem?.enabled = true
            if let users = results {
                if users.count > 0 {
                    print("results \(users)")
                    self.goToUserBrowser(users)
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
    
    func goToUserBrowser(users: [PFUser]) {
        // TODO
        guard let controller = UIStoryboard(name: "People", bundle: nil).instantiateViewControllerWithIdentifier("InviteViewController") as? InviteViewController else { return }
//        let nav = UINavigationController(rootViewController: controller)
        controller.people = users
        //self.navigationController?.presentViewController(nav, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
