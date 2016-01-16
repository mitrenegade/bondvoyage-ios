//
//  UIColor+BVColors.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/16/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

extension UIColor {
    class func BV_defaultBlueColor() -> UIColor {
        return colorFromRGB(red: 79, green: 129, blue: 170)
    }

    class func BV_primaryActionBlueColor() -> UIColor {
        return colorFromRGB(red: 74, green: 144, blue: 226)
    }

    private class func colorFromRGB(red red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor.init(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
}