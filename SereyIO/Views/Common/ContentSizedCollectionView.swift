//
//  ContentSizedCollectionView.swift
//  SereyIO
//
//  Created by Panha Uy on 4/7/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

final class ContentSizedCollectionView: UICollectionView {
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
}
