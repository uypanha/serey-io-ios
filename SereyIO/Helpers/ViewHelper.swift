//
//  ViewHelper.swift
//  SereyIO
//
//  Created by Mäd on 27/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import SnapKit

class ViewHelper {
    
    static func prepareScrollView(completion: @escaping (UIView) -> Void) -> UIScrollView {
        let scrollView = UIScrollView().then {
            $0.backgroundColor = .clear
            $0.alwaysBounceVertical = true
        }
        
        let view = UIView()
        scrollView.addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        completion(view)
        return scrollView
    }
}
