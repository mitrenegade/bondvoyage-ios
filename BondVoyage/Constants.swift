//
//  Constants.swift
//  BondVoyage
//
//  Created by Bobby Ren on 12/17/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import Foundation
import UIKit

let TESTING: Bool = false
let PHILADELPHIA_LAT = 39.949508
let PHILADELPHIA_LON = -75.171886
let BOSTON_LAT = 42.3583038
let BOSTON_LON = -71.0714141

let PARSE_APP_ID: String = "CgME1GrgMhiBQInE72auuNajzaCnhFRtqoyFbGIg"
let PARSE_CLIENT_KEY: String = "C3rX83IXHsXnwFjAlPS4ci7HhsgHYlN06IvYfJRa"

let PARSE_LOCAL: Bool = true
let PARSE_APP_ID_LOCAL: String = "BONDVOYAGE_LOCAL_APP_ID"

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
    
    private class func colorFromRGB(red red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
    private class func colorFromRGBWithAlpha(red red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: alpha)
    }
    
    class func randomColor() -> UIColor {
        let colors = [UIColor.redColor(), UIColor.blueColor(), UIColor.greenColor(), UIColor.yellowColor(), UIColor.purpleColor(), UIColor.brownColor()]
        let index = Int(arc4random_uniform(UInt32(colors.count)))
        return colors[index]
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