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

// search options
var RANGE_SELECTOR_MAX = 85
var RANGE_SELECTOR_MIN = 1

class Constants: NSObject {
    class func rangeSliderTrackColor() -> UIColor{
        return UIColor(red: 167.0/256.0, green: 168.0/256.0, blue: 171.0/256.0, alpha: 1.0)
    }
    
    class func rangeSliderHighlightColor() -> UIColor{
        return self.blueColor()//UIColor(red: 40.0/256.0, green: 175.0/256.0, blue: 163.0/256.0, alpha: 1.0)
    }
    
    class func rangeSliderThumbColor() -> UIColor {
        return UIColor(red: 212.0/256.0, green: 210.0/256.0, blue: 203.0/256.0, alpha: 1.0)
    }

    class func blueColor() -> UIColor {
        return UIColor(red: 79.0/255.0, green: 129.0/255.0, blue: 170.0/255.0, alpha: 1)
    }
}