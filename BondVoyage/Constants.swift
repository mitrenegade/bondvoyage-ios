//
//  Constants.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/17/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import Foundation
import UIKit

let CITIES = ["Boston", "Athens", "Other"]

let TESTING: Bool = false
let PHILADELPHIA_LAT = 39.949508
let PHILADELPHIA_LON = -75.171886
let BOSTON_LAT = 42.3583038
let BOSTON_LON = -71.0714141

let PARSE_APP_ID: String = "CgME1GrgMhiBQInE72auuNajzaCnhFRtqoyFbGIg"
let PARSE_SERVER_URL_LOCAL: String = "http://localhost:1337/parse"
let PARSE_SERVER_URL = "https://bondvoyage-server.herokuapp.com/parse"
let PARSE_CLIENT_KEY = "unused"
let PARSE_LOCAL: Bool = true

let QB_APP_ID: UInt = 46441
let QB_AUTH_KEY = "Mw99rUvp7ApXAjS"
let QB_ACCOUNT_KEY = "qezMRGfSugu3WHCiT1wg"
let QB_AUTH_SECRET = "HCXw5O6bqy4kXAJ"

// MARK: Call
let SESSION_TIMEOUT_INTERVAL: TimeInterval = 30

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
var RANGE_DISTANCE_MAX = 54
var RANGE_DISTANCE_MIN = 0


enum Gender: String {
    case Female, Male, Other
}

enum VoyagerType: String {
    case NewToCity = "New to the city"
    case Local = "Local to the city"
    case Leisure = "Traveling for leisure"
    case Business = "Traveling for business"
}

enum Group: String {
    case Solo
    case SignificantOther
    case Family
    case Friends
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
    
    class func BV_defaultBlueColor() -> UIColor {
        return colorFromRGB(red: 79, green: 129, blue: 170)
    }
    
    class func BV_primaryActionBlueColor() -> UIColor {
        return colorFromRGB(red: 74, green: 144, blue: 226)
    }
    
    class func BV_backgroundGrayColor() -> UIColor {
        return colorFromRGBWithAlpha(red: 173, green: 173, blue: 173, alpha: 0.8)
    }
    
    class func BV_navigationBarGrayColor() -> UIColor {
        return colorFromRGBWithAlpha(red: 219, green: 219, blue: 219, alpha: 0.88)
    }
    
    fileprivate class func colorFromRGB(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    fileprivate class func colorFromRGBWithAlpha(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    class func randomColor() -> UIColor {
        let colors = [UIColor.red, UIColor.blue, UIColor.green, UIColor.yellow, UIColor.purple, UIColor.brown]
        let index = Int(arc4random_uniform(UInt32(colors.count)))
        return colors[index]
    }

}

extension String {
    var capitalizeFirst: String {
        if isEmpty { return "" }
        var result = self
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).uppercased())
        return result
    }
    
}
