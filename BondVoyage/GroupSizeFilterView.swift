//
//  GroupSizeFilterView.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/11/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class GroupSizeFilterView: RangeFilterView {
    func configure(minSize: Int, maxSize: Int, lower: Int, upper: Int) {
        self.setSliderRange(min: minSize, max: maxSize)
        self.rangeSlider?.lowerValue = Double(lower)
        self.rangeSlider?.upperValue = Double(upper)
        self.rangeSlider?.setNeedsDisplay()
    }
}
