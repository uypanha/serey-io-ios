//
//  VoteDialogProtocol.swift
//  SereyIO
//
//  Created by Panha Uy on 4/16/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import LSDialogViewController

protocol VoteDialogProtocol {
    
    func showVoteDialog(_ viewModel: VoteDialogViewModel)
    
    func showDownvoteDialog(_ viewModel: DownvoteDialogViewModel)
}

extension VoteDialogProtocol where Self: UIViewController {
    
    func showVoteDialog(_ viewModel: VoteDialogViewModel) {
        let voteDialogViewController = VoteDialogViewController(self)
        voteDialogViewController.viewModel = viewModel
        
        // dismiss old dialog befire display new one
        self.dismissDialogViewController(.zoomInOut)
        self.presentDialogViewController(voteDialogViewController, animationPattern: .zoomInOut, backgroundViewType: .solid, dismissButtonEnabled: true, completion: nil)
    }
    
    func showDownvoteDialog(_ viewModel: DownvoteDialogViewModel) {
        let voteDialogViewController = DownvoteDialogViewController(self)
        voteDialogViewController.viewModel = viewModel
        
        // dismiss old dialog befire display new one
        self.dismissDialogViewController(.zoomInOut)
        self.presentDialogViewController(voteDialogViewController, animationPattern: .zoomInOut, backgroundViewType: .solid, dismissButtonEnabled: true, completion: nil)
    }
}
