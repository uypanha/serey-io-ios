//
//  BrowseDrumsViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 14/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class BrowseDrumsViewController: BaseDrumListingViewController {
    
    lazy var drumLogoImageView: UIImageView = {
        return .init(image: R.image.drumsLogo()).then {
            $0.contentMode = .scaleAspectFit
            $0.snp.makeConstraints { make in
                make.width.height.equalTo(24)
            }
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.leftBarButtonItems?.append(.init(customView: self.drumLogoImageView))
        self.navigationItem.rightBarButtonItem = .init(image: R.image.tabNotification(), style: .plain, target: nil, action: nil)
    }
}

// MARK: - TabBarControllerDelegate
extension BrowseDrumsViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = .init(title: R.string.home.home.localized(), image: R.image.tabHome(), selectedImage: R.image.tabHomeSelected())
    }
}
