//
//  CategoryCell.swift
//  BondVoyage
//
//  Created by Bobby Ren on 3/28/16.
//  Copyright © 2016 RenderApps. All rights reserved.
//

import UIKit
import AsyncImageView

class CategoryCell: UITableViewCell {
    @IBOutlet weak var viewFrame: UIView!
    @IBOutlet weak var bgImage: AsyncImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var shadowLayer: CALayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.viewFrame!.layer.shadowOpacity = 1
        self.viewFrame!.layer.shadowRadius = 5
        self.viewFrame!.layer.shadowColor = UIColor.blackColor().CGColor
        self.viewFrame!.layer.shadowOffset = CGSizeMake(3, 3)
        
        self.titleLabel!.layer.shadowOpacity = 1
        self.titleLabel!.layer.shadowRadius = 3
        self.titleLabel!.layer.shadowColor = UIColor.blackColor().CGColor
        self.titleLabel!.layer.shadowOffset = CGSizeMake(3, 3)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
