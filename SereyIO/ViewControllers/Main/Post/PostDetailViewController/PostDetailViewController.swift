//
//  PostDetailViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 2/5/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

class PostDetailViewController: BaseViewController {
    
    var viewModel: PostDetailViewModel!
    
    init(viewModel: PostDetailViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.prepareViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
