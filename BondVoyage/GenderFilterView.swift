//
//  GenderFilterView.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/11/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class GenderFilterView: SingleFilterView {
    var genderOptions: [String] = [Gender.Male.rawValue, Gender.Female.rawValue, "All"]

    func configure(currentSelection: String) {
        self.setSliderRange(min: 0, max: self.genderOptions.count - 1)
        if let index: Int = self.genderOptions.indexOf(currentSelection) {
            self.slider?.currentValue = Double(index)
        }

        self.updateLabel()
        self.slider?.setNeedsDisplay()
    }
    
    override func updateLabel() {
        var text = "Unspecified"
        if self.slider != nil {
            let index:Int = Int(round(self.slider!.currentValue))
            text = genderOptions[index]
        }
        self.label.text = "Gender: \(text)"
    }
}
