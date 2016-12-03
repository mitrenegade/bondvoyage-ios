//
//  ActivitiesNavigationController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/3/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class ActivitiesNavigationController: ConfigurableNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func loadDefaultRootViewController() {
        let user = PFUser.current() as? User
        if let city = user?.city {
            super.loadDefaultRootViewController()
        }
        else {
            // Do any additional setup after loading the view.
            let storyboard = UIStoryboard(name: "City", bundle: nil)
            if let controller = storyboard.instantiateInitialViewController() {
                self.setViewControllers([controller], animated: false)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
