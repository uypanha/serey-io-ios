//
//  ChooseCategorySheetViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/26/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources
import RxBinding

class ChooseCategorySheetViewModel: BaseViewModel, CollectionMultiSectionsProviderModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case itemSelected(IndexPath)
    }
    
    enum ViewToPresent {
        case dismiss
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let cells: BehaviorRelay<[SectionItem]>
    
    let categories: BehaviorRelay<[DiscussionCategoryModel]>
    let selectedCategory: BehaviorRelay<DiscussionCategoryModel?>
    
    init(categories: [DiscussionCategoryModel], _ selectedCategory: BehaviorRelay<DiscussionCategoryModel?>) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.cells = .init(value: [])
        self.categories = .init(value: categories)
        self.selectedCategory = selectedCategory
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ChooseCategorySheetViewModel {
    
    func prepareCells(_ categories: [DiscussionCategoryModel]) -> [SectionItem] {
        var sectionItems: [SectionItem] = []
        var items: [CellViewModel] = [FilterHeaderCellViewModel(self.selectedCategory)]
        categories.forEach { mainCategory in
            if mainCategory.name != "All" {
                // ignore "All" category
                items.append(HeaderCellViewModel(mainCategory.name))
                items.append(ProductCategoryCellViewModel(mainCategory, selectedCategory: selectedCategory, title: "ALL"))
                mainCategory.sub?.forEach { category in
                    items.append(ProductCategoryCellViewModel(category, selectedCategory: selectedCategory))
                }
            }
        }
        sectionItems.append(.init(items: items))
        return sectionItems
    }
}

// MARK: - Action Handlers
fileprivate extension ChooseCategorySheetViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? ProductCategoryCellViewModel {
            if item.category.value.name != self.selectedCategory.value?.name {
                self.selectedCategory.accept(item.category.value)
                self.shouldPresent(.dismiss)
            }
        }
    }
}

// MARK: - SetUp RxObservers
extension ChooseCategorySheetViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpActionObservers()
    }
    
    func setUpContentChangedObservers() {
        self.categories.asObservable()
            .map { self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                }
            }) ~ self.disposeBag
    }
}
