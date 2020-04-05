//
//  PostCommentView.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/10/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class PostCommentView: NibView {

    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var commentTextField: UITextField!
    
    var viewModel: PostCommentViewModel? {
        didSet {
            guard let viewModel = self.viewModel else { return }
            
            self.disposeBag = DisposeBag()
            self.disposeBag ~ [
                viewModel.profileViewModel ~> self.profileView.rx.profileViewModel,
                viewModel.upVoteCount ~> self.upVoteButton.rx.title(for: .normal),
                viewModel.downVoteCount ~> self.downVoteButton.rx.title(for: .normal)
            ]
            
            viewModel.commentTextFieldViewModel.dispose()
            viewModel.commentTextFieldViewModel.bind(with: self.commentTextField)
        }
    }
}

#if os(iOS) || os(tvOS)

import RxSwift
import UIKit

extension Reactive where Base: PostCommentView {
    
    /// Bindable sink for `profileViewModel` property.
    internal var viewModel: Binder<PostCommentViewModel?> {
        return Binder(self.base) { postCommentView, model in
            postCommentView.viewModel = model
        }
    }
}

#endif
