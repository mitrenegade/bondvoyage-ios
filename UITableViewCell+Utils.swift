//
//  UITableViewCell+Utils.swift
//  BondVoyage
//
//  Created by Amy Ly on 12/13/15.
//  Copyright © 2015 RenderApps. All rights reserved.
//

import UIKit

extension UITableViewCell {

    func adjustTableViewCellSeparatorInsets(cell :UITableViewCell) {
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }

}
