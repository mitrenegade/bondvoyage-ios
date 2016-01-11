//
//  GenderFilterView.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/2/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class GenderFilterView: BaseFilterView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.setupSlider()
    }
 
    override func setupSlider() {
        super.setupSlider()

        self.label.text = "Gender"
    }

}
