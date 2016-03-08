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
            var max:Double = self.rangeSlider!.upperValue
            if self.rangeSlider!.upperValue > 50 && self.rangeSlider!.upperValue <= 52 {
                max = 100
            }
            else if self.rangeSlider!.upperValue > 52 {
                max = 500
            }
            self.label.text = NSString(format: "Within %2.1f miles", max) as String
        }
    }

    override func setSliderValues(lower lower: Int, upper: Int) {
        // HACK: always hides lower value
        self.rangeSlider?.lowerValue = -100
        if upper <= 50 {
            self.rangeSlider!.upperValue = min(self.rangeSlider!.maximumValue, Double(upper))
        }
        else if upper <= 100 {
            self.rangeSlider!.upperValue = 52
        }
        else {
            self.rangeSlider!.upperValue = 54
        }
        self.updateLabel()
    }
}
