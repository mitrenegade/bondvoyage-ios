//
//  GroupSizeFilterView.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/2/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

var GROUP_SIZE_MAX = 15
var GROUP_SIZE_MIN = 1

class GroupSizeFilterView: BaseFilterView {
    var slider: RangeSlider = RangeSlider()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.height = 60
        
        self.setupSlider()
    }

    func setupSlider() {
        self.slider.frame = CGRectMake(0, 0, self.frame.size.width, 40)
        self.addSubview(self.slider)
        self.setupSlider(lower: GROUP_SIZE_MIN, upper: GROUP_SIZE_MAX)
    }
    
    func setupSlider(lower lower: Int, upper: Int) {
        self.slider.addTarget(self, action: "rangeSliderValueChanged:",
            forControlEvents: .ValueChanged)
        self.slider.addTarget(self, action: "rangeSliderValueEnded:",
            forControlEvents: .TouchUpInside)
        
        self.slider.maximumValue = Double(GROUP_SIZE_MAX) // must setup max value first
        self.slider.minimumValue = Double(GROUP_SIZE_MIN)
        
        self.slider.lowerValue = Double(lower)
        self.slider.upperValue = Double(upper)
    }
    
    func rangeSliderValueChanged(rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.lowerValue) \(rangeSlider.upperValue))")
    }
    
    func rangeSliderValueEnded(rangeSlider: RangeSlider) {
        // TODO: make it snap
    }
}
