//
//  GroupSizeFilterView.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/2/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class RangeFilterView: BaseFilterView {
    var rangeSlider: BVRangeSlider?
    
    override func setupSlider() {
        self.slider = BVRangeSlider()
        super.setupSlider()
        self.rangeSlider = self.slider as? BVRangeSlider

        self.setSliderRange(min: RANGE_SELECTOR_MIN, max: RANGE_SELECTOR_MAX)
        self.rangeSlider?.lowerValue = Double(RANGE_SELECTOR_MIN)
        self.rangeSlider?.upperValue = Double(RANGE_SELECTOR_MAX)

        self.label.text = "Range"
    }
    
    func sliderValueChanged(sender: UIControl) {
        if let slider: BVRangeSlider = sender as? BVRangeSlider {
            print("Range slider value changed: (\(slider.lowerValue) \(slider.upperValue))")
            self.updateLabel()
        }
    }
    
    func sliderValueEnded(sender: UIControl) {
        // TODO: make it snap
    }
}
