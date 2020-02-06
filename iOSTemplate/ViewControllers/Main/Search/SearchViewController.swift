//
//  SearchViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class SearchViewController: BaseViewController {
    
    @IBOutlet weak var searchTextField: PaddingTextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - Preparations & Tools
extension SearchViewController {
    
    func setUpViews() {
        self.searchTextField.makeMeCircular()
        self.searchTextField.rightView = UIImageView(image: R.image.tabSearch()?.image(withTintColor: .black))
        self.searchTextField.rightViewMode = .always
        
//        prepareTableView()
    }
    
}

// MARK: - TabBarControllerDelegate
extension SearchViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = UITabBarItem(title: "Search", image: R.image.tabSearch(), selectedImage: R.image.tabSearchSelected())
        self.tabBarItem?.tag = tag
    }
}
