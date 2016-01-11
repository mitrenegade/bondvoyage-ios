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
    
    var slider: RangeSlider
    var label: UILabel

    required init?(coder aDecoder: NSCoder) {
        self.slider = RangeSlider()
        self.label = UILabel()
        super.init(coder: aDecoder)
        
        self.addSubview(self.slider)
        self.label.font = UIFont(name: "Lato-Regular", size: 17.0)
        self.label.textColor = UIColor.whiteColor()
        self.label.textAlignment = .Center
        self.addSubview(self.label)
    }

    func openHeight() -> CGFloat {
        return 80
    }
    
    func setupSlider() {
        
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
        self.slider.frame = CGRectMake(self.frame.size.width * 0.1, self.frame.size.height * 2 / 8.0, self.frame.size.width * 0.8, self.frame.size.height * 2 / 8.0)
        self.label.frame = CGRectMake(self.frame.size.width * 0.1, self.frame.size.height * 4 / 8.0, self.frame.size.width * 0.8, self.frame.size.height * 2 / 8.0)
    }
}
