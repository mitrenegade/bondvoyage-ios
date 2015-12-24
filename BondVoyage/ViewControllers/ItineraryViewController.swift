//
//  ItineraryViewController.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/12/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit

let kEmbedItineraryTableViewSegue:String = "embedItineraryTableViewSegue"

class ItineraryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // use this example query
        let interests: [String] = ["books", "cooking"]
        let gender: [Gender] = [.Male]
        let ageRange: [Int] = [24, 36]
        let numRange: [Int] = [] // not used
        UserRequest.userQuery(interests, gender: gender, ageRange: ageRange, numRange: numRange) { (results, error) -> Void in
            if error != nil {
                print("user match error: \(error)")
            }
            else {
                print("user match results: \(results)")
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBarHidden = false
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kEmbedItineraryTableViewSegue {
            // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller.
        }
    }
}
