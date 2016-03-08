//
//  DistanceFilterView.swift
//  BondVoyage
//
//  Created by Bobby Ren on 3/8/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class DistanceFilterView: RangeFilterView {
    // HACK: this is a range filter but only display/read max range
    func configure(maxDist: Int, upper: Int) {
        self.setSliderRange(min: RANGE_DISTANCE_MIN, max: maxDist)
        self.setSliderValues(lower: -100, upper: upper)
    }
    
    override func updateLabel() {
        if self.rangeSlider != nil {
            let max:Double = self.rangeSlider!.upperValue
            self.label.text = NSString(format: "Within %2.1f miles", max) as String
        }
    }

    override func setSliderValues(lower lower: Int, upper: Int) {
        // HACK: always hides lower value
        self.rangeSlider?.lowerValue = -100
        self.rangeSlider!.upperValue = min(self.rangeSlider!.maximumValue, Double(upper))
        self.updateLabel()
    }
}
