//
//  ContentSizedTableView.swift
//  SereyIO
//
//  Created by Phanha Uy on 12/19/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

final class ContentSizedTableView: UITableView {
    
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        var size = self.contentSize
        size.height += self.contentInset.top + self.contentInset.bottom
        return size
    }

    override var contentSize: CGSize {
        didSet{
            self.invalidateIntrinsicContentSize()
        }
    }
}
