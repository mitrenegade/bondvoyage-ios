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
        self.label.textColor = UIColor.white
        self.label.textAlignment = .center
        self.addSubview(self.label)

        self.slider!.trackTintColor = Constants.sliderTrackColor()
        self.slider!.thumbTintColor = Constants.sliderThumbColor()

        self.slider!.addTarget(self, action: "sliderValueChanged:",
            for: .valueChanged)
        self.slider!.addTarget(self, action: "sliderValueEnded:",
            for: .touchUpInside)
    }
    
    func setSliderRange(min: Int, max: Int) {
        self.slider!.maximumValue = Double(max) // must setup max value first
        self.slider!.minimumValue = Double(min)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.slider?.frame = CGRect(x: self.frame.size.width * 0.1, y: self.frame.size.height * 2 / 8.0, width: self.frame.size.width * 0.8, height: self.frame.size.height * 2 / 8.0)
        self.label.frame = CGRect(x: self.frame.size.width * 0.1, y: self.frame.size.height * 4 / 8.0, width: self.frame.size.width * 0.8, height: self.frame.size.height * 2 / 8.0)
        if self.slider != nil {
            self.label.center = CGPoint(x: self.slider!.center.x, y: (self.slider!.center.y + self.frame.size.height) / 2)
        }
    }
    
    func updateLabel() {
        preconditionFailure("Must be implemented by subclass")
    }
}
