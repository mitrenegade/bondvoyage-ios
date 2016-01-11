//
//  AgeRangeFilterView.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/2/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class AgeRangeFilterView: BaseFilterView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSlider()
    }
    
    override func setupSlider() {
        super.setupSlider()
        self.setSliderRange(min: AGE_RANGE_MIN, max: AGE_RANGE_MAX)
        self.setSliderValues(lower: AGE_RANGE_MIN, upper: AGE_RANGE_MAX)

        self.label.text = "Age range"
    }

}