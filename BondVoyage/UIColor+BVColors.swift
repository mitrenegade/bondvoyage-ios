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