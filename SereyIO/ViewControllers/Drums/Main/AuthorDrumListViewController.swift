//
//  AuthorDrumListViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 14/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

class AuthorDrumListViewController: BaseDrumListingViewController {
    
    override init(viewModel: BrowseDrumsViewModel) {
        super.init(viewModel: viewModel)
        
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.viewModel.authorDrumTitle()
    }

}
