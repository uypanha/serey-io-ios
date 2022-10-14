//
//  PostDrumViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 11/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import RxCocoa
import RxSwift
import RxBinding
import SnapKit
import RichEditorView
import AlignedCollectionViewFlowLayout
import RxKeyboard

class PostDrumViewController: BaseViewController, KeyboardController, LoadingIndicatorController, AlertDialogController {
    
    lazy var keyboardDisposeBag = DisposeBag()
    
    var editorHeightContraint: ConstraintMakerEditable!
    var bottomConstraint: LayoutConstraint!
    var scrollView: UIScrollView!
    
    lazy var postButton: UIBarButtonItem = {
        return .init(title: R.string.post.post.localized(), style: .plain, target: nil, action: nil).then {
            $0.tintColor = .color(.primary)
        }
    }()
    
    lazy var editor: SRichEditorView = {
        return .init(frame: .init())
    }()
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 54))
        toolbar.options = CRichEditorOption.allExeptAttachment
        toolbar.tintColor = UIColor.black
        return toolbar
    }()
    
    lazy var collectionView: ContentSizedCollectionView = {
        return .init(frame: .init(), collectionViewLayout: AlignedCollectionViewFlowLayout().then {
            $0.horizontalAlignment = .left
            $0.minimumLineSpacing = self.menuSpace
            $0.minimumInteritemSpacing = self.menuSpace
            $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            $0.itemSize = .init(width: 1, height: 1)
        }).then {
            $0.delegate = self
            $0.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
            $0.isScrollEnabled = false
            $0.register(UploadImageCollectionViewCell.self, isNib: false)
            $0.register(ImageCollectionViewCell.self, isNib: false)
            $0.register(QuotedDrumCollectionViewCell.self, isNib: false)
        }
    }()
    
    var menuColumn: CGFloat { return 3 }
    var menuSpace: CGFloat { return 16 }
    
    var minContentHeight: CGFloat = 48
    var isFirstInitial: Bool = false
    
    var viewModel: PostDrumViewModel!
    lazy var fileMediaHelper: MediaPickerHelper = {
        return .init(withPresenting: self).then {
            $0.singleSelect = false
        }
    }()
    
    override func loadView() {
        self.view = self.prepareViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpEditorView(self.editor)
        self.navigationItem.rightBarButtonItem = self.postButton
        setUpRxObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.keyboardDisposeBag = .init()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUpKeyboardObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.editor.placeholder = "What's on your mind, \(AuthData.shared.username ?? "")?"
    }
}

// MARK: - Preparations & Tools
extension PostDrumViewController {
    
    func getGridItemSize() -> CGSize {
        let viewWidth = self.collectionView.frame.width - 32
        let itemWidth = (viewWidth - self.menuSpace * (self.menuColumn - 1)) / self.menuColumn
        let itemHeight = itemWidth.rounded(.down)
        return CGSize(width: itemWidth.rounded(.down), height: itemHeight)
    }
}

extension PostDrumViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? UploadImageCollectionViewCell)?.setHighlighted(true, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? UploadImageCollectionViewCell)?.setHighlighted(false, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.didAction(with: .itemSelected(indexPath))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let _ = self.viewModel.item(at: indexPath) as? QuotedDrumCellViewModel {
            return .init(width: collectionView.frame.width - 32, height: 100)
        }
        return getGridItemSize()
    }
}

// MARK: - SetUp RxObservers
private extension PostDrumViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
        setUpShouldPresentError()
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
    
    func setUpControlObservers() {
        self.postButton.rx.tap.asObservable()
            .map { _ in PostDrumViewModel.Action.postPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.collectionView.rx.items) { [unowned self] collectionView, index, item in
                let indexPath = IndexPath(row: index, section: 0)
                switch item {
                case is UploadImageCellViewModel:
                    let cell: UploadImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.cellModel = item as? UploadImageCellViewModel
                    cell.updateSize(self.getGridItemSize())
                    return cell
                case is ImageCollectionCellViewModel:
                    let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.cellModel = item as? ImageCollectionCellViewModel
                    cell.updateSize(self.getGridItemSize())
                    return cell
                case is QuotedDrumCellViewModel:
                    let cell: QuotedDrumCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.updateSize(.init(width: self.collectionView.frame.width - 32, height: 80))
                    cell.cellModel = item as? QuotedDrumCellViewModel
                    return cell
                default:
                    return .init()
                }
            }.disposed(by: self.disposeBag)
        
        self.fileMediaHelper.selectedPhotoSubject.asObservable()
            .subscribe(onNext: { [weak self] pickers in
                self?.viewModel.didAction(with: .didPhotoSelected(pickers))
            }) ~ self.disposeBag
        
        self.viewModel.isPostEnabled.asObservable()
            ~> self.postButton.rx.isEnabled
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .bottomListViewController(let viewModel):
                    let bottomMenuViewController = BottomMenuViewController(viewModel)
                    self?.present(bottomMenuViewController, animated: true, completion: nil)
                case .choosePhotoController(let assets):
                    self?.fileMediaHelper.selectedAssets = assets
                    self?.fileMediaHelper.showImagePicker()
                case .takePhotoController:
                    DispatchQueue.main.async {
                        self?.fileMediaHelper.showCameraPicker()
                    }
                case .loading(let loading):
                    loading ? self?.showLoading() : self?.dismissLoading()
                case .dismiss:
                    self?.dismiss(animated: true)
                }
            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentError() {
        self.viewModel.shouldPresentError.asObservable()
            .subscribe(onNext: { [weak self] error in
                self?.showDialogError(error)
            }) ~ self.disposeBag
    }
    
    func setUpKeyboardObservers() {
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardHeight in
                if let _self = self {
                    _self.bottomConstraint.constant = -keyboardHeight
                    UIView.animate(withDuration: 0.3, animations: {
                        _self.view.layoutIfNeeded()
                    })
                }
            }).disposed(by: self.keyboardDisposeBag)
    }
}
