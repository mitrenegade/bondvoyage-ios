//
//  AgeRangeFilterView.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/11/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class AgeRangeFilterView: RangeFilterView {
    func configure(minAge: Int, maxAge: Int, lower: Int, upper: Int) {
        self.setSliderRange(min: minAge, max: maxAge)
        self.rangeSlider?.lowerValue = Double(lower)
        self.rangeSlider?.upperValue = Double(upper)
        self.rangeSlider?.setNeedsDisplay()
    }
}
