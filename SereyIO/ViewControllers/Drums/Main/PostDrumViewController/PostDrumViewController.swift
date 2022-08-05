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

class PostDrumViewController: BaseViewController, KeyboardController {
    
    var editorHeightContraint: ConstraintMakerEditable!
    var bottomConstraint: ConstraintMakerEditable!
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
        }
    }()
    
    var menuColumn: CGFloat { return 3 }
    var menuSpace: CGFloat { return 16 }
    
    var minContentHeight: CGFloat = 48
    var isFirstInitial: Bool = false
    
    var viewModel: PostDrumViewModel = .init()
    lazy var fileMediaHelper: MediaPickerHelper = {
        return .init(withPresenting: self)
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
        return getGridItemSize()
    }
}

// MARK: - SetUp RxObservers
private extension PostDrumViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.collectionView.rx.items) { collectionView, index, item in
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
                default:
                    return .init()
                }
            }.disposed(by: self.disposeBag)
        
        self.fileMediaHelper.selectedPhotoSubject.asObservable()
            .subscribe(onNext: { [weak self] picker in
                self?.viewModel.didAction(with: .didPhotoSelected(picker))
            }) ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .bottomListViewController(let viewModel):
                    let bottomMenuViewController = BottomMenuViewController(viewModel)
                    self?.present(bottomMenuViewController, animated: true, completion: nil)
                case .choosePhotoController:
                    self?.fileMediaHelper.showImagePicker()
                case .takePhotoController:
                    DispatchQueue.main.async {
                        self?.fileMediaHelper.showCameraPicker()
                    }
                }
            }) ~ self.disposeBag
    }
}
