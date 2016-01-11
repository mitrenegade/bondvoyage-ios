//
//  GroupSizeFilterView.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/2/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class GroupSizeFilterView: BaseFilterView {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.height = 60
        
        self.setupSlider()
    }
    
    override func setupSlider() {
        super.setupSlider()
        self.setSliderRange(min: GROUP_SIZE_MIN, max: GROUP_SIZE_MAX)
        self.setSliderValues(lower: GROUP_SIZE_MIN, upper: GROUP_SIZE_MAX)
    }
    
    func rangeSliderValueChanged(rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.lowerValue) \(rangeSlider.upperValue))")
    }
    
    func rangeSliderValueEnded(rangeSlider: RangeSlider) {
        // TODO: make it snap
    }
}
