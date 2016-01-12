//
//  GroupSizeFilterView.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/11/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class GroupSizeFilterView: RangeFilterView {
    func configure(minSize: Int, maxSize: Int, lower: Int, upper: Int) {
        self.setSliderRange(min: minSize, max: maxSize)
        self.setSliderValues(lower: lower, upper: upper)
        self.rangeSlider?.setNeedsDisplay()

        self.updateLabel()
        self.rangeSlider?.setNeedsDisplay()
    }
    
    override func updateLabel() {
        if self.rangeSlider != nil {
            let min:Int = Int(round(self.rangeSlider!.lowerValue))
            let max:Int = Int(round(self.rangeSlider!.upperValue))
            self.label.text = "\(min) to \(max) people"
        }
    }
}
