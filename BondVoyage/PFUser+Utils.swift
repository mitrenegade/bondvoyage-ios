//
//  PFUser+Utils.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/10/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import Foundation
import Parse


let date = NSDate()
let calendar = NSCalendar.currentCalendar()
let components = calendar.components([.Day , .Month , .Year], fromDate: date)

extension PFUser {

    var age: Int {
        get {
            let currentYear = components.year
            let age = currentYear - (self.valueForKey("birthYear") as! Int)
            return age
        }
    }

    var gender: String {
        get {
            return self.valueForKey("gender") as! String
        }
    }

}


