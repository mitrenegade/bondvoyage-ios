//
//  String+Utils.swift
//  BondVoyage
//
//  Created by Bobby Ren on 10/29/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

extension String {
    func attributedString(substring: String, size: CGFloat) -> NSAttributedString? {
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
        attributes[NSFontAttributeName] = UIFont.systemFontOfSize(size)
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: self, attributes: attributes) as NSMutableAttributedString
        let range = (self as NSString).rangeOfString(substring)
        
        var otherAttrs = Dictionary<String, AnyObject>()
        otherAttrs[NSForegroundColorAttributeName] = UIColor.darkGrayColor()
        attributedString.addAttributes(otherAttrs, range: range)
        
        return attributedString
    }
}