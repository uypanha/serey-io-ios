//
//  LineIndicatorTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 9/12/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class LineIndicatorTableViewCell: BaseTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.separatorInset = .init(top: 0, left: self.frame.width, bottom: 0, right: 0)
    }
}
