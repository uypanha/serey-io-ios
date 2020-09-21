//
//  VotersViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 5/17/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class VotersViewController: ListTableViewController<VoterListViewModel> {

    override func viewDidLoad() {
        self.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
}
