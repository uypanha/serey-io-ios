//
//  PostDrumViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import DKImagePickerController

class PostDrumViewModel: BaseViewModel, CollectionSingleSecitionProviderModel, ShouldPresent, ShouldReactToAction {
    
    enum Action {
        case itemSelected(IndexPath)
        case didPhotoSelected([PickerFileModel])
        case postPressed
    }
    
    enum ViewToPresent {
        case bottomListViewController(BottomListMenuViewModel)
        case choosePhotoController([DKAsset])
        case takePhotoController
        case loading(Bool)
        case dismiss
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let pickerModels: BehaviorRelay<[PickerFileModel]>
    let cells: BehaviorRelay<[CellViewModel]>
    
    let descriptionTextField: TextFieldViewModel
    let isPostEnabled: BehaviorSubject<Bool>
    
    let isUploading: BehaviorRelay<Bool>
    let drumService: DrumsService
    let fileUploadService: FileUploadService
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.pickerModels = .init(value: [])
        self.cells = .init(value: [])
        
        self.descriptionTextField = .textFieldWith(title: "", validation: .notEmpty)
        self.isPostEnabled = .init(value: false)
        
        self.isUploading = .init(value: false)
        self.drumService = .init()
        self.fileUploadService = .init()
        super.init()
        
        setUpRxObservsers()
    }
}

// MARK: - Preparations & Tools
extension PostDrumViewModel {
    
    private func prepareCells() -> [CellViewModel] {
        var items: [CellViewModel] = []
        items.append(UploadImageCellViewModel(R.image.iconUploadImage()))
        
        items.append(contentsOf: self.pickerModels.value.map {
            ImageCollectionCellViewModel(pickerModel: $0).then {
                self.setUpImageCellObservers($0)
            }
        })
        
        return items
    }
    
    private func update(_ pickerModels: [PickerFileModel]) {
        self.pickerModels.accept(pickerModels)
    }
    
    private func removeImage(_ pickerModel: PickerFileModel) {
        let pickerModels = self.pickerModels.value.filter { $0.dkAsset.localIdentifier != pickerModel.dkAsset.localIdentifier }
        self.pickerModels.accept(pickerModels)
    }
}

// MARK: - Action Handlers
fileprivate extension PostDrumViewModel {
    
    func handleItemSeleted(_ indexPath: IndexPath) {
        if let _ = self.item(at: indexPath) as? UploadImageCellViewModel {
            self.handleUploadImagePressed()
        }
    }
    
    func handleUploadImagePressed() {
        let items: [ImageTextCellViewModel] = UploadImageOption.allCases.map { $0.cellModel }
        
        let bottomListMenuViewModel = BottomListMenuViewModel(header: "Profile Picture", items)
        bottomListMenuViewModel.shouldSelectMenuItem
            .subscribe(onNext: { [unowned self] cellModel in
                if let cellModel = cellModel as? UploadImageOptionCellViewModel {
                    switch cellModel.option {
                    case .selectFromPhotos:
                        let assets = self.pickerModels.value.map { $0.dkAsset }
                        self.shouldPresent(.choosePhotoController(assets))
                    case .takeNewPhoto:
                        self.shouldPresent(.takePhotoController)
                    }
                }
            }) ~ self.disposeBag
        
        self.shouldPresent(.bottomListViewController(bottomListMenuViewModel))
    }
    
    func handlePostPressed() {
        self.isUploading.accept(true)
        let uploadedUrls = self.pickerModels.value.map { $0.uploadedUrl }
        if uploadedUrls.contains(where: { $0 == nil }) {
            self.uploadPhotos { failed in
                if failed {
                    self.isUploading.accept(false)
                }
            }
        } else {
            self.submitDrumPost()
        }
    }
}

// MARK: - SetUP RxObservers
private extension PostDrumViewModel {
    
    func setUpRxObservsers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.pickerModels.asObservable()
            .map { _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.descriptionTextField.textFieldText.asObservable()
            .map { _ in self.descriptionTextField.validate() }
            ~> self.isPostEnabled
            ~ self.disposeBag
        
        self.isUploading.asObservable()
            .map { ViewToPresent.loading($0) }
            ~> self.shouldPresentSubject
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSeleted(indexPath)
                case .didPhotoSelected(let pickerModels):
                    self?.update(pickerModels)
                case .postPressed:
                    self?.handlePostPressed()
                }
            }) ~ self.disposeBag
    }
    
    func setUpImageCellObservers(_ cellModel: ImageCollectionCellViewModel) {
        cellModel.shouldReactToAction.asObservable()
            .subscribe(onNext: { [weak self] _ in
                if let pickerModel = cellModel.pickerModel.value {
                    self?.removeImage(pickerModel)
                }
            }) ~ self.disposeBag
    }
}
