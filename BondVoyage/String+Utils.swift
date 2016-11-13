//
//  String+Utils.swift
//  BondVoyage
//
//  Created by Bobby Ren on 10/29/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

extension String {
    func attributedString(_ substring: String, size: CGFloat) -> NSAttributedString? {
        var attributes = Dictionary<String, AnyObject>()
        attributes[NSForegroundColorAttributeName] = UIColor.white
        attributes[NSFontAttributeName] = UIFont.systemFont(ofSize: size)
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: self, attributes: attributes) as NSMutableAttributedString
        let range = (self as NSString).range(of: substring)
        
        var otherAttrs = Dictionary<String, AnyObject>()
        otherAttrs[NSForegroundColorAttributeName] = UIColor.darkGray
        attributedString.addAttributes(otherAttrs, range: range)
        
        return attributedString
    }
}
