//
//  GenderFilterView.swift
//  BondVoyage
//
//  Created by Amy Ly on 1/2/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit

class GenderFilterView: BaseFilterView {

    override convenience init(frame: CGRect) {
        self.init(frame: frame)
        self.buttonTag = 1
        self.height = 40
    }

}
