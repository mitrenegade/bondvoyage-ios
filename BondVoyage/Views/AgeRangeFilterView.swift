//
//  AgeRangeFilterView.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/2/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class AgeRangeFilterView: BaseFilterView {

    override convenience init(frame: CGRect) {
        self.init(frame: frame)
        self.buttonTag = 3
        self.height = 80
    }
}
