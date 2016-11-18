//
//  GenderFilterView.swift
//  BondVoyage
//
//  Created by Bobby Ren on 1/11/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//
// not used

import UIKit

// not used
enum GenderPrefs: String {
    case Female, Male, Other, All
}

class GenderFilterView: SingleFilterView {
    var genderOptions: [GenderPrefs] = [.Male, .Female, .Other, .All]
    
    override func setupSlider() {
        super.setupSlider()

        // make sure slider has the right number of options; default to all search
        self.configure(.All)
    }
    
    func configure(_ currentSelection: GenderPrefs) {
        self.setSliderRange(min: 0, max: self.genderOptions.count)
        if let index: Int = self.genderOptions.index(of: currentSelection) {
            self.slider?.currentValue = Double(index)
        }

        self.updateLabel()
        self.snap()
        self.slider?.setNeedsDisplay()
    }
    
    override func updateLabel() {
        var text = "Unspecified"
        if self.slider != nil {
            let index:Int = Int(self.slider!.currentValue)
            print("value \(self.slider!.currentValue) index: \(index) genderOptions: \(genderOptions[index])")
            text = genderOptions[index].rawValue
        }
        self.label.text = "Gender: \(text)"
    }
    
    func setSliderSelection(_ genderPref: String) {
        for pref in self.genderOptions {
            if pref.rawValue == genderPref {
                self.configure(pref)
            }
        }
    }
    
    func currentGenderPrefs() -> [String] {
        // returns slider selection as an array of strings. if All is selected, includes all Gender types
        let currentPref: GenderPrefs = genderOptions[Int(self.slider!.currentValue)]
        var prefs: [String] = [currentPref.rawValue]
        if currentPref == .All {
            prefs = [GenderPrefs.Female.rawValue, GenderPrefs.Male.rawValue, GenderPrefs.Other.rawValue]
        }
        return prefs
    }
}
