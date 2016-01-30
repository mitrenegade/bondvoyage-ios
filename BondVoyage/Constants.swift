//
//  Constants.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/17/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import Foundation
import UIKit

let PARSE_APP_ID: String = "CgME1GrgMhiBQInE72auuNajzaCnhFRtqoyFbGIg"
let PARSE_CLIENT_KEY: String = "C3rX83IXHsXnwFjAlPS4ci7HhsgHYlN06IvYfJRa"

// default slider range min/max
var RANGE_SELECTOR_MAX = 100
var RANGE_SELECTOR_MIN = 1
var SINGLE_SELECTOR_MAX = 3
var SINGLE_SELECTOR_MIN = 0

// specific slider range min/max
var RANGE_AGE_MAX = 85
var RANGE_AGE_MIN = 16
var RANGE_GROUP_MAX = 20
var RANGE_GROUP_MIN = 1

enum Gender: String {
    case Female, Male, Other
}

enum GenderPrefs: String {
    case Female, Male, Other, All
}

class Constants: NSObject {
    class func sliderTrackColor() -> UIColor{
        return UIColor(red: 167.0/256.0, green: 168.0/256.0, blue: 171.0/256.0, alpha: 1.0)
    }
    
    class func sliderHighlightColor() -> UIColor{
        return self.blueColor()
    }
    
    class func sliderThumbColor() -> UIColor {
        return UIColor(red: 212.0/256.0, green: 210.0/256.0, blue: 203.0/256.0, alpha: 1.0)
    }

    class func blueColor() -> UIColor {
        return UIColor(red: 79.0/255.0, green: 129.0/255.0, blue: 170.0/255.0, alpha: 1)
    }

    class func lightBlueColor() -> UIColor {
        return UIColor(red: 200.0/255.0, green: 230.0/255.0, blue: 233.0/255.0, alpha: 1)
    }
}