//
//  BaseFilterView.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/4/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

/* THIS IS AN ABSTRACT CLASS, DO NOT INSTANTIATE */

class BaseFilterView: UIView {
    var buttonTag: Int!
    var height: CGFloat! // TODO: don't need this, use frame.height

    required init?(coder aDecoder: NSCoder) {
        self.buttonTag = 0
        self.height = 0
        super.init(coder: aDecoder)
    }
}
