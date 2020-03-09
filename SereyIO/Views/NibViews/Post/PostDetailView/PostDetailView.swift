//
//  PostDetailView.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/7/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RichEditorView

class PostDetailView: NibView {
    
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editorView: SRichEditorView!
    @IBOutlet weak var publishTimeLabel: UILabel!
    @IBOutlet weak var editorHeightConstraint: NSLayoutConstraint!
    
    var viewModel: PostCellViewModel? {
        didSet {
            guard let cellModel = self.viewModel else { return }
            
            self.disposeBag ~ [
                cellModel.profileViewModel ~> self.profileView.rx.profileViewModel,
                cellModel.authorName ~> self.profileNameLabel.rx.text,
                cellModel.publishedAt ~> self.publishTimeLabel.rx.text,
                cellModel.titleText ~> self.titleLabel.rx.text,
                cellModel.contentDesc ~> self.editorView.rx.html
            ]
        }
    }
    
    override func xibSetup() {
        super.xibSetup()
        
        editorView.isScrollEnabled = false
        editorView.editingEnabled = false
        editorView.delegate = self
    }
}

// MARK:
extension PostDetailView: RichEditorDelegate {
    
    func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
        self.editorHeightConstraint.constant = CGFloat(height)
    }
    
    func richEditorDidLoad(_ editor: RichEditorView) {
        editorView.editorMargin = 16
        editor.customCssAndJS()
        editor.setFontSize(14)
        let html = editor.html
        editor.html = html
    }
}

#if os(iOS) || os(tvOS)

import RxSwift
import UIKit

extension Reactive where Base: PostDetailView {
    
    /// Bindable sink for `profileViewModel` property.
    internal var viewModel: Binder<PostCellViewModel?> {
        return Binder(self.base) { profileView, model in
            profileView.viewModel = model
        }
    }
    
}

#endif
