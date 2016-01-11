//
//  GenderFilterView.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/2/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class SingleFilterView: BaseFilterView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setSliderRange(min: 0, max: 2)
        self.setupSlider()
    }
 
    override func setupSlider() {
        super.setupSlider()
        self.setSliderRange(min: RANGE_SELECTOR_MIN, max: RANGE_SELECTOR_MAX)
        self.slider.currentValue = Double(RANGE_SELECTOR_MAX + RANGE_SELECTOR_MIN) / 2

        self.label.text = "Gender"
    }

    func sliderValueChanged(sender: UIControl) {
        if let slider: BVSlider = sender as? BVSlider {
            print("Range slider value changed: \(slider.currentValue)")
            let val:Int = Int(round(slider.currentValue))
            self.label.text = "\(val)"
        }
    }
    
    func sliderValueEnded(sender: UIControl) {
        // TODO: make it snap
    }
}
