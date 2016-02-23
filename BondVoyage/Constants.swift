//
//  Constants.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/17/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import Foundation
import UIKit

let TESTING: Bool = true
let PHILADELPHIA_LAT = 39.949508
let PHILADELPHIA_LON = -75.171886

let PARSE_APP_ID: String = "CgME1GrgMhiBQInE72auuNajzaCnhFRtqoyFbGIg"
let PARSE_CLIENT_KEY: String = "C3rX83IXHsXnwFjAlPS4ci7HhsgHYlN06IvYfJRa"

let GOOGLE_API_IOS_KEY: String = "AIzaSyACcyQL3r_ryyj6qlOSplxf3ucsguEIWg4"
let GOOGLE_API_SERVER_KEY: String = "AIzaSyAVhw7NunYCQpo9D1-eTa73xGGBj4ZeHpI" // used to make data requests through website

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

extension String {
    var capitalizeFirst: String {
        if isEmpty { return "" }
        var result = self
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).uppercaseString)
        return result
    }
    
}