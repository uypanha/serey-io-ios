//
//  CommentReplyTableViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class CommentReplyTableViewController: ListTableViewController<CommentsListViewModel> {
    
    override func viewDidLoad() {
        self.sepereatorStyle = .none
        self.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
