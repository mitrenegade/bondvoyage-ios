//
//  GenderFilterView.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/2/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class SingleFilterView: BaseFilterView {
 
    override func setupSlider() {
        self.slider = BVSlider()
        super.setupSlider()

        self.slider!.trackTintColor = Constants.sliderHighlightColor()

        self.setSliderRange(min: SINGLE_SELECTOR_MIN, max: SINGLE_SELECTOR_MAX)
        self.slider!.currentValue = Double(self.slider!.minimumValue + self.slider!.maximumValue) / 2

        self.label.text = "Select"
    }
    
    func sliderValueChanged(_ sender: UIControl) {
        if let slider: BVSlider = sender as? BVSlider {
            print("Range slider value changed: \(slider.currentValue)")
        }
        self.updateLabel()
    }
    
    func sliderValueEnded(_ sender: UIControl) {
        // TODO: make it snap
        self.snap()
    }
    
    func snap() {
        self.slider!.currentValue = Double(Int(self.slider!.currentValue)) + 0.5
    }
}
