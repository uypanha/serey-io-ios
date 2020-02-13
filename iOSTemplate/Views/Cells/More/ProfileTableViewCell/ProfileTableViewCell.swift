//
//  ProfileTableViewCell.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 2/11/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class ProfileTableViewCell: BaseTableViewCell {
    
    var cellModel: ProfileCellViewModel? {
        didSet {
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.accessoryView = ViewUtiliesHelper.prepareIndicatorAccessory()
    }
}
