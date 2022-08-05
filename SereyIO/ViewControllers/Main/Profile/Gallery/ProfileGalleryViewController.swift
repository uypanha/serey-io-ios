//
//  ProfileGalleryViewController.swift
//  SereyIO
//
//  Created by Mäd on 27/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Then
import AlignedCollectionViewFlowLayout

class ProfileGalleryViewController: BaseViewController, AlertDialogController, LoadingIndicatorController {
    
    lazy var titleLabel: UILabel = {
        return .createLabel(22, weight: .medium, textColor: .black)
    }()
    
    lazy var tipsLabel: UILabel = {
        return .createLabel(14, weight: .regular, textColor: UIColor(hexString: "#606060"))
    }()
    
    lazy var tipsDescriptionLabel: UILabel = {
        return .createLabel(14, weight: .regular, textColor: UIColor(hexString: "#606060")).then {
            $0.numberOfLines = 0
        }
    }()
    
    lazy var collectionView: ContentSizedCollectionView = {
        return .init(frame: .init(), collectionViewLayout: AlignedCollectionViewFlowLayout().then {
            $0.horizontalAlignment = .left
            $0.minimumLineSpacing = self.menuSpace
            $0.minimumInteritemSpacing = self.menuSpace
            $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            $0.itemSize = .init(width: 1, height: 1)
        }).then {
            $0.contentInset = .init(top: 16, left: 16, bottom: 16, right: 16)
            $0.register(ImageCollectionViewCell.self, isNib: false)
            $0.register(UploadImageCollectionViewCell.self, isNib: false)
            $0.isScrollEnabled = false
            $0.delegate = self
        }
    }()
    
    lazy var updateButton: UIBarButtonItem = {
        return .init(title: "Update", style: .plain, target: nil, action: nil)
    }()
    
    lazy var noProfileView: NoProfilePictureView = {
        return .init()
    }()
    
    lazy var fileMediaHelper: MediaPickerHelper = .init(withPresenting: self)
    
    var menuColumn: CGFloat { return 3 }
    var menuSpace: CGFloat { return 16 }
    
    var viewModel: ProfileGalleryViewModel!
    
    override func loadView() {
        self.view = self.prepareViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = self.updateButton
        setUpRxObservers()
        self.viewModel.downloadData()
        
        self.noProfileView.didUploadPressed = {
            self.viewModel.didAction(with: .uploadPressed)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.removeNavigationBarBorder()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.titleLabel.text = "Profile Picture Gallery"
        self.tipsLabel.text = "Tips:"
        self.tipsDescriptionLabel.text = "Tap on any profile picture to update. You also can delete the profile picture by taping on delete icon. Be aware that current profile picture can’t be deleted."
    }
}

// MARK: - Preparations & Tools
extension ProfileGalleryViewController {
    
    func getGridItemSize() -> CGSize {
        let viewWidth = self.collectionView.frame.width - 32
        let itemWidth = (viewWidth - self.menuSpace * (self.menuColumn - 1)) / self.menuColumn
        let itemHeight = itemWidth.rounded(.down)
        return CGSize(width: itemWidth.rounded(.down), height: itemHeight)
    }
}

extension ProfileGalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? UploadImageCollectionViewCell)?.setHighlighted(true, animated: true)
        (collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell)?.setHighlighted(true, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? UploadImageCollectionViewCell)?.setHighlighted(false, animated: true)
        (collectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell)?.setHighlighted(false, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getGridItemSize()
    }
}


// MARK: - SetUp RxObservers
extension ProfileGalleryViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpControlObservers() {
        self.collectionView.rx.itemSelected
            .map { ProfileGalleryViewModel.Action.itemSelected($0) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.updateButton.rx.tap.asObservable()
            .map { ProfileGalleryViewModel.Action.updatePressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.collectionView.rx.items) { [unowned self] collectionView, index, item in
                let indexPath = IndexPath(row: index, section: 0)
                switch item {
                case is ProfilePictureCellViewModel:
                    let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.cellModel = item as? ProfilePictureCellViewModel
                    cell.updateSize(self.getGridItemSize())
                    return cell
                case is UploadImageCellViewModel:
                    let cell: UploadImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                    cell.cellModel = item as? UploadImageCellViewModel
                    cell.updateSize(self.getGridItemSize())
                    return cell
                default:
                    return .init()
                }
            } ~ self.disposeBag
        
        self.viewModel.isUpdateButonHidden.asObservable()
            .subscribe(onNext: { [weak self] isHidden in
                self?.navigationItem.rightBarButtonItem = isHidden ? nil : self?.updateButton
            }) ~ self.disposeBag
        
        self.viewModel.isDescriptionHidden.asObservable()
            ~> self.tipsDescriptionLabel.rx.isHidden
            ~ self.disposeBag
        
        self.viewModel.isDescriptionHidden.asObservable()
            ~> self.tipsLabel.rx.isHidden
            ~ self.disposeBag
        
        self.viewModel.isNoProfileViewHidden.asObservable()
            ~> self.noProfileView.rx.isHidden
            ~ self.disposeBag
        
        self.fileMediaHelper.selectedPhotoSubject.asObservable()
            .map { ProfileGalleryViewModel.Action.photoSelected($0.first!) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .openMediaPicker:
                    self?.fileMediaHelper.showImagePicker()
                case .showAlertDialog(let alertDialogModel):
                    self?.showDialog(alertDialogModel)
                case .loading(let loading, let message):
                    loading ? self?.showLoading(message ?? "") : self?.dismissLoading()
                case .dismiss:
                    DispatchQueue.main.async {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }) ~ self.disposeBag
    }
}
