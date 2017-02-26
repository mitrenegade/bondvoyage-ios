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
        let user = PFUser.current() as? User
        if let city = user?.city, !city.isEmpty {
            return // city exists
        }
        else {
            // Do any additional setup after loading the view.
            let storyboard = UIStoryboard(name: "City", bundle: nil)
            if let nav = storyboard.instantiateInitialViewController() as? UINavigationController, let controller = nav.viewControllers[0] as? CityViewController {
                controller.delegate = self
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ActivitiesNavigationController: CityViewDelegate {
    func didFinishSelectCity() {
        self.dismiss(animated: true, completion: nil)
    }
}
