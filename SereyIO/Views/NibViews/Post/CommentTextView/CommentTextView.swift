//
//  CommentTextView.swift
//  SereyIO
//
//  Created by Panha Uy on 4/15/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class CommentTextView: NibView {
    
    @IBOutlet weak var textView: UIPlaceHolderTextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var viewModel: CommentTextViewModel? {
        didSet {
            self.disposeBag = DisposeBag()
            guard let viewModel = self.viewModel else { return }
            
            viewModel.commentTextFieldViewModel.dispose()
            viewModel.commentTextFieldViewModel.bind(with: textView)
            viewModel.commentTextFieldViewModel.textFieldText.asObservable()
                .map { $0 != nil && !$0!.isEmpty }
                ~> self.sendButton.rx.isEnabled
                ~ self.disposeBag
            
            self.sendButton.rx.tap.asObservable()
                .map { CommentTextViewModel.Action.sendCommentPressed }
                ~> viewModel.didActionSubject
                ~ self.disposeBag
            
            viewModel.isUploading.asObservable()
                .subscribe(onNext: { [weak self] isUploading in
                    self?.textView.isEditable = !isUploading
                    self?.loadingIndicator.isHidden = !isUploading
                    self?.sendButton.isHidden = isUploading
                    if isUploading {
                        self?.loadingIndicator.startAnimating()
                    }
                }) ~ self.disposeBag
        }
    }
    
    override func xibSetup() {
        super.xibSetup()
        
        self.backgroundColor = .clear
        self.textView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        
        self.sendButton.tintColor = .color(.primary)
        self.sendButton.setImage(R.image.sendIcon()?.image(withTintColor: .lightGray), for: .disabled)
        self.sendButton.setImage(R.image.sendIcon()?.image(withTintColor: .color(.primary)), for: .normal)
    }
}

#if os(iOS) || os(tvOS)

extension Reactive where Base: CommentTextView {
    
    /// Bindable sink for `profileViewModel` property.
    internal var viewModel: Binder<CommentTextViewModel?> {
        return Binder(self.base) { commentTextView, model in
            commentTextView.viewModel = model
        }
    }
}

#endif
