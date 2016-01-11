//
//  GenderFilterView.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/11/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class GenderFilterView: SingleFilterView {
    var genderOptions: [String] = ["None"]

    func configure(genderOptions: [String], currentSelection: String) {
        self.genderOptions = genderOptions
        self.setSliderRange(min: 0, max: self.genderOptions.count - 1)
        if let index: Int = self.genderOptions.indexOf(currentSelection) {
            self.slider?.currentValue = Double(index)
        }
        self.slider?.setNeedsDisplay()
    }
}
