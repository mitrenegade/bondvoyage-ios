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

    func getGender() -> String {
        return self.valueForKey("gender") as! String
    }

    func getAge() -> Int {
        let currentYear = components.year
        let age = currentYear - (self.valueForKey("birthYear") as! Int)
        return age
    }
}


