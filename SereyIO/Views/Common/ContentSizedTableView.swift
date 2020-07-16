//
//  ContentSizedTableView.swift
//  SereyIO
//
//  Created by Phanha Uy on 12/19/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

final class ContentSizedTableView: UITableView {
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return self.contentSize
    }

    override var contentSize: CGSize {
        didSet{
            self.invalidateIntrinsicContentSize()
        }
    }
}
