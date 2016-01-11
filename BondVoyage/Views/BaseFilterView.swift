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
    
    var slider: BVSlider?
    var label: UILabel = UILabel()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addSubview(label)
        
        self.setupSlider()
    }

    func openHeight() -> CGFloat {
        return 80
    }
    
    func setupSlider() {
        self.addSubview(self.slider!)
        self.label.font = UIFont(name: "Lato-Regular", size: 17.0)
        self.label.textColor = UIColor.whiteColor()
        self.label.textAlignment = .Center
        self.addSubview(self.label)

        self.slider!.trackTintColor = Constants.rangeSliderTrackColor()
        self.slider!.thumbTintColor = Constants.rangeSliderThumbColor()

        self.slider!.addTarget(self, action: "sliderValueChanged:",
            forControlEvents: .ValueChanged)
        self.slider!.addTarget(self, action: "sliderValueEnded:",
            forControlEvents: .TouchUpInside)
    }
    
    func setSliderRange(min min: Int, max: Int) {
        self.slider!.maximumValue = Double(max) // must setup max value first
        self.slider!.minimumValue = Double(min)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.slider?.frame = CGRectMake(self.frame.size.width * 0.1, self.frame.size.height * 2 / 8.0, self.frame.size.width * 0.8, self.frame.size.height * 2 / 8.0)
        self.label.frame = CGRectMake(self.frame.size.width * 0.1, self.frame.size.height * 4 / 8.0, self.frame.size.width * 0.8, self.frame.size.height * 2 / 8.0)
    }
}
