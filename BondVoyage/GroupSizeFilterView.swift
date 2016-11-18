//
//  GroupSizeFilterView.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/11/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class GroupSizeFilterView: RangeFilterView {
    func configure(_ minSize: Int, maxSize: Int, lower: Int, upper: Int) {
        self.setSliderRange(min: minSize, max: maxSize)
        self.setSliderValues(lower: lower, upper: upper)
    }
    
    override func updateLabel() {
        if self.rangeSlider != nil {
            let min:Int = Int(self.rangeSlider!.lowerValue)
            let max:Int = Int(self.rangeSlider!.upperValue)
            self.label.text = "\(min) to \(max) people"
        }
    }
}
