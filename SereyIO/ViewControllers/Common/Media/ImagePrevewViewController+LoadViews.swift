//
//  ImagePrevewViewController+LoadViews.swift
//  SereyIO
//
//  Created by Panha Uy on 22/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit

extension ImagePrevewViewController {
    
    func prepareViews() -> UIView {
        let mainView = UIView()
        
        self.scrollView = .init()
        self.imageView = .init()
        self.imageView.contentMode = .scaleAspectFit
        
        mainView.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.scrollView.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        return mainView
    }
}
