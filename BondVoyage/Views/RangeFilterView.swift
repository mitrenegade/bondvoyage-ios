//
//  GroupSizeFilterView.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/2/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class RangeFilterView: BaseFilterView {
    var rangeSlider: RangeSlider?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.slider = RangeSlider()
        self.rangeSlider = self.slider as? RangeSlider

        self.setupSlider()
    }
    
    override func setupSlider() {
        super.setupSlider()
        self.setSliderRange(min: RANGE_SELECTOR_MIN, max: RANGE_SELECTOR_MAX)
        self.rangeSlider?.lowerValue = Double(RANGE_SELECTOR_MIN)
        self.rangeSlider?.upperValue = Double(RANGE_SELECTOR_MAX)

        self.label.text = "Range"
    }
    
    func sliderValueChanged(sender: UIControl) {
        if let slider: RangeSlider = sender as? RangeSlider {
            print("Range slider value changed: (\(slider.lowerValue) \(slider.upperValue))")
            let min:Int = Int(round(slider.lowerValue))
            let max:Int = Int(round(slider.upperValue))
            self.label.text = "\(min) - \(max)"
        }
    }
    
    func sliderValueEnded(sender: UIControl) {
        // TODO: make it snap
    }
}
