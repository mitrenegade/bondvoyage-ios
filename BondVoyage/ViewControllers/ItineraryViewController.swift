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

        UserRequest.usersMatchingInterests(["books", "music"]) { (results, error) -> Void in
            if error != nil {
                print("user match error: \(error)")
            }
            else {
                print("user match results: \(results)")
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == kEmbedItineraryTableViewSegue {
            // Get the new view controller using segue.destinationViewController.
            // Pass the selected object to the new view controller.
        }
    }
}
