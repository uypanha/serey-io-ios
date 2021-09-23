//
//  BaseTableViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxSwift

class BaseTableViewCell: UITableViewCell {
    
    lazy var disposeBag: DisposeBag = {
        return DisposeBag()
    }()
    
    lazy var borderViews: [UIView] = []
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
    
    func addBorder(edges: UIRectEdge, color: UIColor, inset: CGFloat = 0.0, thickness: CGFloat = 1.0) {
        borderViews.append(contentsOf: self.addBorders(edges: edges, color: color, inset: inset, thickness: thickness))
    }
    
    func removeAllBorders() {
        borderViews.forEach { borderView in
            borderView.removeFromSuperview()
        }
        borderViews.removeAll()
    }
}
