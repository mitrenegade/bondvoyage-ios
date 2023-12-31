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
    var currentActivity: Activity?
    
    var fromTime: NSDate?
    var toTime: NSDate?
    
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

        // check if user currently has an activity
        self.tableView.allowsSelection = false
        self.userHasActiveActivityForCategory(category: nil) { (activity) in
            if let activity = activity, let categoryString = activity.category {
                self.newCategory = CategoryFactory.categoryForString(categoryString)
                self.currentActivity = activity
                self.tableView.allowsSelection = false
                self.requestActivities()
            }
            else {
                self.currentActivity = nil
                self.tableView.allowsSelection = true
            }
        }
    }
    
    func userHasActiveActivityForCategory(category: CATEGORY?, completion: @escaping ((Activity?)->Void)) {
        guard let user = PFUser.current() as? User else {
            completion(nil)
            return
        }
        user.fetchIfNeededInBackground(block: { (results, error) in
            if let error = error {
                completion(nil)
                return
            }
            
            Activity.queryActivities(user: user, category: category, city: nil, completion: { (results, error) in
                if let activities = results, activities.count > 0 {
                    for activity in activities {
                        guard let expiration = activity.expiration, let status = activity.status, expiration.timeIntervalSinceNow > 0, status == "active" else {
                            continue
                        }
                        if let category: String = activity.category {
                            completion(activity)
                            return
                        }
                    }
                    completion(nil)
                }
                else {
                    completion(nil)
                }
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tableView.allowsSelection = true
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
        self.userHasActiveActivityForCategory(category: category) { (activity) in
            if let activity = activity {
                // go directly to activities for existing activity
                self.currentActivity = activity
                self.requestActivities()
            }
            else {
                self.currentActivity = nil
                self.showDateSelector()
            }
        }
    }
    
    // MARK: - Date selector
    func showDateSelector() {
        guard self.datesController == nil else {
            return
        }
        guard let controller = UIStoryboard(name: "Activities", bundle: nil).instantiateViewController(withIdentifier: "DatesViewController") as? DatesViewController else {
            return
        }
        
        self.datesController = controller
        self.datesController?.delegate = self
        
        self.fromTime = nil
        self.toTime = nil
        
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
        self.view.addGestureRecognizer(tap)
    }
    
    func didSelectDates(_ startDate: Date?, endDate: Date?) {
        guard let category = self.newCategory else { return }
        
        self.hideDateSelector()
        
        print("dates selected: \(startDate) to \(endDate)")
        self.fromTime = startDate as NSDate?
        self.toTime = endDate as NSDate?
        
        // create an activity
        var city = "Boston"
        let user = PFUser.current() as? User
        if let userCity = user?.city, !userCity.isEmpty {
            city = userCity
        }
        
        Activity.createActivity(category: category, city: city, fromTime: self.fromTime, toTime: self.toTime) { (result, error) in
            if let error = error {
                print("error creating activity: \(error)")
                if error.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                        PFUser.logOut()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logout"), object: nil)
                    })
                    return
                }
                let message = "There was a problem loading activities. Please try again"
                self.simpleAlert("Could not select category", defaultMessage: message, error: error)
                
                self.currentActivity = nil
            }
            else {
                print("result: \(result)")
                self.currentActivity = result
                self.requestActivities()
            }
        }
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
        if let recognizers = self.view.gestureRecognizers {
            for recognizer in recognizers {
                self.view.removeGestureRecognizer(recognizer)
            }
        }
    }
    
    // MARK: - Activities
    func requestActivities() {
        guard let category = self.newCategory else {
            self.tableView.allowsSelection = true
            return
        }
        
        // search for other activities
        Activity.queryActivities(user: nil, category: category, city: self.currentActivity?.city) { (results, error) in
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            self.tableView.allowsSelection = true
            if results != nil {
                self.goToActivities(activities: results)
            }
            else {
                if error != nil && error!.code == 209 {
                    self.simpleAlert("Please log in again", message: "You have been logged out. Please log in again to browse activities.", completion: { () -> Void in
                        PFUser.logOut()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logout"), object: nil)
                    })
                    return
                }
                let message = "There was a problem loading activities. Please try again"
                self.simpleAlert("Could not select category", defaultMessage: message, error: error)
            }
        }
    }
    
    func goToActivities(activities: [Activity]?) {
        performSegue(withIdentifier: "GoToActivities", sender: activities)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToActivities" {
            if let controller = segue.destination as? InviteViewController, let activities = sender as? [Activity] {
                controller.activities = activities
                controller.category = self.newCategory
            }
        }
    }
}
