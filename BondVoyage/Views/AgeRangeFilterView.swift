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
        self.buttonTag = 3
        self.height = 70
    }
}