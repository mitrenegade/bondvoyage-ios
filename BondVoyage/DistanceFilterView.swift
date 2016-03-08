//
//  DistanceFilterView.swift
//  BondVoyage
//
//  Created by Bobby Ren on 3/8/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class DistanceFilterView: RangeFilterView {
    func configure(minDist: Int, maxDist: Int, lower: Int, upper: Int) {
        self.setSliderRange(min: minDist, max: maxDist)
        self.setSliderValues(lower: lower, upper: upper)
    }
    
    override func updateLabel() {
        if self.rangeSlider != nil {
            let min:Double = self.rangeSlider!.lowerValue
            let max:Double = self.rangeSlider!.upperValue
            self.label.text = NSString(format: "%2.1f to %2.1f miles", min, max) as String
        }
    }
}
