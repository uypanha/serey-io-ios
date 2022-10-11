//
//  PostDetailView.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/7/20.
//  Copyright © 2020 Serey IO. All rights reserved.
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
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var profileViewGesture: UITapGestureRecognizer? {
        didSet {
            guard let gesture = self.profileViewGesture else { return }
            
            self.profileView.isUserInteractionEnabled = true
            self.profileView.addGestureRecognizer(gesture)
        }
    }
    
    private var profileLabelGesture: UITapGestureRecognizer? {
        didSet {
            guard let gesture = self.profileLabelGesture else { return }
            
            self.profileNameLabel.isUserInteractionEnabled = true
            self.profileNameLabel.addGestureRecognizer(gesture)
        }
    }
    
    var viewModel: PostDetailCellViewModel? {
        didSet {
            self.disposeBag = DisposeBag()
            guard let cellModel = self.viewModel else { return }
            
            self.disposeBag ~ [
                cellModel.profileViewModel ~> self.profileView.rx.profileViewModel,
                cellModel.authorName ~> self.profileNameLabel.rx.text,
                cellModel.publishedAt ~> self.publishTimeLabel.rx.text,
                cellModel.titleText ~> self.titleLabel.rx.text,
                cellModel.contentDesc ~> self.editorView.rx.html
            ]
            
            self.setUpRxObservers(cellModel)
        }
    }
    
    override func xibSetup() {
        super.xibSetup()
        
        editorView.isScrollEnabled = false
        editorView.editingEnabled = false
        editorView.delegate = self
        
        setUpViews()
    }
    
    private func setUpViews() {
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 1, height: 1)
            layout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        self.collectionView.register(SubPostCategoryCollectionViewCell.self)
        self.profileViewGesture = UITapGestureRecognizer()
        self.profileLabelGesture = UITapGestureRecognizer()
    }
}

// MARK: - SetUp RxObservers
extension PostDetailView {
    
    func setUpRxObservers(_ viewModel: PostDetailCellViewModel) {
        self.profileViewGesture?.rx.event.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.onProfilePressed()
            }).disposed(by: self.disposeBag)
        
        self.profileLabelGesture?.rx.event.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel?.onProfilePressed()
            }).disposed(by: self.disposeBag)
        
        setUpCollectionView(viewModel)
    }
    
    func setUpCollectionView(_ viewModel: PostDetailCellViewModel) {
        
        viewModel.cells.asObservable()
            .bind(to: self.collectionView.rx.items) { collectionView, index, item in
                switch item {
                case is CategoryCellViewModel:
                    let cell: SubPostCategoryCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: IndexPath(row: index, section: 0))
                    cell.cellModel = item as? CategoryCellViewModel
                    return cell
                default:
                    return UICollectionViewCell()
                }
            } ~ self.disposeBag
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
    
    func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool {
        return false
    }
}

#if os(iOS) || os(tvOS)

import RxSwift
import UIKit

extension Reactive where Base: PostDetailView {
    
    /// Bindable sink for `profileViewModel` property.
    internal var viewModel: Binder<PostDetailCellViewModel?> {
        return Binder(self.base) { profileView, model in
            profileView.viewModel = model
        }
    }
    
}

#endif
