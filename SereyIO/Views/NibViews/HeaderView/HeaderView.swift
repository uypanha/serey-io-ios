//
//  HeaderView.swift
//  Emergency
//
//  Created by Phanha Uy on 11/27/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

class HeaderView: NibView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leadingConstrant: NSLayoutConstraint!
    
    private var titleText: String? {
        didSet {
            self.titleLabel.text = self.titleText
        }
    }
}

extension HeaderView {
    
    func configureData(_ title: String?, leftInset: CGFloat = 32) {
        self.titleText = title
        self.leadingConstrant.constant = leftInset
    }
}
