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

class PostDrumViewModel: BaseViewModel, CollectionSingleSecitionProviderModel, ShouldPresent, ShouldReactToAction {
    
    enum Action {
        case itemSelected(IndexPath)
        case didPhotoSelected([PickerFileModel])
    }
    
    enum ViewToPresent {
        case bottomListViewController(BottomListMenuViewModel)
        case choosePhotoController
        case takePhotoController
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let pickerModels: BehaviorRelay<[PickerFileModel]>
    let cells: BehaviorRelay<[CellViewModel]>
    
    override init() {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.pickerModels = .init(value: [])
        self.cells = .init(value: [])
        super.init()
        
        setUpRxObservsers()
    }
}

// MARK: - Preparations & Tools
extension PostDrumViewModel {
    
    private func prepareCells() -> [CellViewModel] {
        var items: [CellViewModel] = []
        items.append(UploadImageCellViewModel(R.image.iconUploadImage()))
        
        items.append(contentsOf: self.pickerModels.value.map { ImageCollectionCellViewModel(image: $0.dkAsset.image) })
        
        return items
    }
    
    private func update(_ pickerModels: [PickerFileModel]) {
        var pickers = self.pickerModels.value
        pickers.append(contentsOf: pickerModels)
        self.pickerModels.accept(pickers)
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
                        self.shouldPresent(.choosePhotoController)
                    case .takeNewPhoto:
                        self.shouldPresent(.takePhotoController)
                    }
                }
            }) ~ self.disposeBag
        
        self.shouldPresent(.bottomListViewController(bottomListMenuViewModel))
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
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSeleted(indexPath)
                case .didPhotoSelected(let pickerModels):
                    self?.update(pickerModels)
                }
            }) ~ self.disposeBag
    }
}
