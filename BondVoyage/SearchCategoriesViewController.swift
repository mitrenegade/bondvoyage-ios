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
            imageView.frame = CGRect(x: 0, y: 0, width: 150, height: 44)
            imageView.contentMode = .scaleAspectFit
            imageView.backgroundColor = Constants.lightBlueColor()
            imageView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: 22)
            self.navigationController!.navigationBar.addSubview(imageView)
            self.navigationController!.navigationBar.barTintColor = Constants.lightBlueColor()
            
            self.setLeftProfileButton()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category: CATEGORY = CATEGORIES[indexPath.row]
        cell.titleLabel!.text = CategoryFactory.categoryReadableString(category)
        cell.backgroundColor = UIColor.clear
        cell.bgImage.image = CategoryFactory.categoryBgImage(category.rawValue)
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CATEGORIES.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
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
    
    func selectCategory(_ category: CATEGORY) {
        self.newCategory = category
        
        self.showDateSelector()
    }
    
    // MARK: - Date selector
    func showDateSelector() {
        guard let controller = UIStoryboard(name: "Activity", bundle: nil).instantiateViewController(withIdentifier: "DatesViewController") as? DatesViewController else {
            return
        }
        
        self.datesController = controller
        self.datesController?.delegate = self
        
        let topOffset: CGFloat = 40 // keep the "I'm in the mood for" exposed
        var frame = self.view.frame
        frame.origin.y = self.view.frame.size.height
        frame.size.height -= topOffset
        controller.view.frame = frame
        controller.willMove(toParentViewController: self)
        self.addChildViewController(controller)
        self.view.addSubview(controller.view)
        frame.origin.y = topOffset
        UIView.animate(withDuration: 0.25, animations: {
            controller.view.frame = frame
        }, completion: { (success) in
            controller.didMove(toParentViewController: self)
        }) 
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideDateSelector))
        self.headerView.addGestureRecognizer(tap)
    }
    
    func didSelectDates(_ startDate: Date?, endDate: Date?) {
        self.hideDateSelector()
        
        print("dates selected: \(startDate) to \(endDate)")
        self.requestActivities()
    }
    
    func hideDateSelector() {
        guard let controller = self.datesController else { return }
        
        var frame = controller.view.frame
        frame.origin.y = frame.size.height
        controller.willMove(toParentViewController: nil)
        UIView.animate(withDuration: 0.25, animations: {
            controller.view.frame = frame
        }, completion: { (success) in
            controller.view.removeFromSuperview()
            controller.removeFromParentViewController()
            self.datesController = nil
        }) 
        if let recognizers = self.headerView.gestureRecognizers {
            for recognizer in recognizers {
                self.headerView.removeGestureRecognizer(recognizer)
            }
        }
    }
    
    // MARK: - Activities
    func requestUsers() {
        guard let category = self.newCategory else { return }
        let interests = [CategoryFactory.interestsForCategory(category)]
        UserRequest.userQuery(interests) { (results, error) in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            if let users = results {
                if users.count > 0 {
                    print("results \(users)")
                    self.goToUserBrowser(users)
                }
                else {
                    // no results, no error
                    var message = "There is no one interested in \(CategoryFactory.categoryReadableString(self.newCategory!)) near you."
                    if PFUser.current() != nil {
                        message = "\(message) For the next hour, other people will be able to search for you and invite you to bond."
                    }
                    
                    self.simpleAlert("No activities nearby", message: message, completion: { () -> Void in
                        self.navigationController?.popToRootViewController(animated: true)
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
    
    func requestActivities() {
        guard let category = self.newCategory else { return }
        
        ActivityRequest.queryActivities(nil, joining: false, categories: cat, location: self.currentLocation, distance: Double(RANGE_DISTANCE_MAX), aboutSelf: self.aboutSelf?.rawValue, aboutOthers: aboutOthersRaw) { (results, error) -> Void in
            self.navigationItem.rightBarButtonItem?.enabled = true
            if results != nil {
                if results!.count > 0 {
                    self.selectedActivities = results
                    self.performSegueWithIdentifier("GoToInvite", sender: nil)
                }
                else {
                    // no results, no error
                    self.createActivityWithCompletion({ (success) in
                        var message = "There is no one interested in \(CategoryFactory.categoryReadableString(self.category!)) near you."
                        if PFUser.currentUser() != nil {
                            if success {
                                message = "\(message) For the next hour, other people will be able to search for you and invite you to bond."
                            }
                            else {
                                message = "\(message) Please try again later."
                            }
                        }
                        
                        self.simpleAlert("No activities nearby", message: message, completion: { () -> Void in
                            self.navigationController?.popToRootViewControllerAnimated(true)
                        })
                    })
                }
            }
            else {
                if error != nil && error!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                        PFUser.logOut()
                        NSNotificationCenter.defaultCenter().postNotificationName("logout", object: nil)
                    })
                    return
                }
                let message = "There was a problem loading matches. Please try again"
                self.simpleAlert("Could not select category", defaultMessage: message, error: error)
            }
        }
    }
    
    func createActivityWithCompletion(completion: ((Bool)->Void)) {
        let ageMin = Int(self.ageFilterView.rangeSlider!.lowerValue)
        let ageMax = Int(self.ageFilterView.rangeSlider!.upperValue)
        
        var aboutOthers = [VoyagerType]()
        for i in 0 ..< self.selectedTypes.count {
            if self.selectedTypes[i] {
                aboutOthers.append(PERSON_TYPES[i])
            }
        }
        let aboutOthersRaw = aboutOthers.map { (v) -> String in
            return v.rawValue
        }
        
        HUD.show(.SystemActivity)
        ActivityRequest.createActivity([self.category!.rawValue], location: self.currentLocation!, locationString: "Boston", aboutSelf: self.aboutSelf?.rawValue, aboutOthers: aboutOthersRaw, ageMin: ageMin, ageMax: ageMax ) { (result, error) -> Void in
            HUD.hide(animated: false, completion: nil)
            if error != nil {
                completion(false)
            }
            else {
                completion(true)
            }
        }
    }

    
    func goToUserBrowser(_ users: [PFUser]) {
        // TODO
        guard let controller = UIStoryboard(name: "People", bundle: nil).instantiateViewController(withIdentifier: "InviteViewController") as? InviteViewController else { return }
//        let nav = UINavigationController(rootViewController: controller)
        controller.people = users
        //self.navigationController?.presentViewController(nav, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
