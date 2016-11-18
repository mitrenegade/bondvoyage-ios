//
//  AgeRangeFilterView.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/11/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class AgeRangeFilterView: RangeFilterView {
    func configure(_ minAge: Int, maxAge: Int, lower: Int, upper: Int) {
        self.setSliderRange(min: minAge, max: maxAge)
        self.setSliderValues(lower: lower, upper: upper)
    }
    
    override func updateLabel() {
        if self.rangeSlider != nil {
            let min:Int = Int(self.rangeSlider!.lowerValue)
            let max:Int = Int(self.rangeSlider!.upperValue)
            self.label.text = "Ages \(min) to \(max)"
        }
    }
}
