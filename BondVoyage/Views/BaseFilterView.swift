//
//  BaseFilterView.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/4/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

/* THIS IS AN ABSTRACT CLASS, DO NOT INSTANTIATE */

class BaseFilterView: UIView {
    
    var height: CGFloat! // TODO: don't need this, use frame.height
    var slider: RangeSlider

    required init?(coder aDecoder: NSCoder) {
        self.height = 0
        self.slider = RangeSlider()
        super.init(coder: aDecoder)
    }

    func setupSlider() {
        self.slider.frame = CGRectZero
        self.addSubview(self.slider)
        
        self.slider.trackHighlightTintColor = Constants.rangeSliderHighlightColor()
        self.slider.trackTintColor = Constants.rangeSliderTrackColor()
        self.slider.thumbTintColor = Constants.rangeSliderThumbColor()

        self.slider.addTarget(self, action: "rangeSliderValueChanged:",
            forControlEvents: .ValueChanged)
        self.slider.addTarget(self, action: "rangeSliderValueEnded:",
            forControlEvents: .TouchUpInside)
    }

    func setSliderValues(lower lower: Int, upper: Int) {
        self.slider.lowerValue = Double(lower)
        self.slider.upperValue = Double(upper)
    }
    
    func setSliderRange(min min: Int, max: Int) {
        self.slider.maximumValue = Double(max) // must setup max value first
        self.slider.minimumValue = Double(min)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.slider.frame = CGRectMake(self.frame.size.width * 0.1, self.frame.size.height * 3 / 8.0, self.frame.size.width * 0.8, self.frame.size.height / 4.0)
    }
}
