//
//  ActivitiesNavigationController.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/3/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import Parse

class ActivitiesNavigationController: ConfigurableNavigationController, CityViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let user = PFUser.current() as? User
        if let city = user?.city, !city.isEmpty {
            return // city exists
        }
        else {
            /* RELEASE 0.6.1: do not show city
             */
            // Do any additional setup after loading the view.
            let storyboard = UIStoryboard(name: "City", bundle: nil)
            if let controller = storyboard.instantiateInitialViewController() as? CityViewController {
                controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didFinishSelectCity() {
        self.dismiss(animated: true, completion: nil)
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
