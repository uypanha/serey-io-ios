//
//  CreatePostViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class CreatePostViewModel: BaseCellViewModel, CollectionSingleSecitionProviderModel, ShouldReactToAction, ShouldPresent, DownloadStateNetworkProtocol {
    
    enum Action {
        case itemSelected(IndexPath)
    }
    
    enum ViewToPresent {
        case selectCategoryController(title: String, viewModel: SelectCategoryViewModel)
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    let cells: BehaviorRelay<[CellViewModel]>
    let categories: BehaviorRelay<[DiscussionCategoryModel]>
    let selectedCategory: BehaviorRelay<DiscussionCategoryModel?>
    let selectedSubCategory: BehaviorRelay<DiscussionCategoryModel?>
    
    let discussionService: DiscussionService
    let isDownloading: BehaviorRelay<Bool>
    
    init(_ type: SubmitPostType) {
        self.cells = BehaviorRelay(value: [])
        self.categories = BehaviorRelay(value: [])
        self.selectedCategory = BehaviorRelay(value: nil)
        self.selectedSubCategory = BehaviorRelay(value: nil)
        self.discussionService = DiscussionService()
        self.isDownloading = BehaviorRelay(value: false)
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension CreatePostViewModel {
    
    func downloadData() {
        if !self.isDownloading.value {
            fetchCategories()
        }
    }
    
    private func fetchCategories() {
        self.isDownloading.accept(true)
        self.discussionService.getCategories()
            .subscribe(onNext: { [weak self] categories in
                self?.isDownloading.accept(false)
                self?.updateData(categories)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension CreatePostViewModel {
    
    class CategoryCellViewModel: TextCellViewModel {
        
        let category: CreatePostViewModel.CategoryCellType
        
        init(_ category: CreatePostViewModel.CategoryCellType, indicatorAccessory: Bool) {
            self.category = category
            super.init(with: category.selectTitle, properties: .defaultProperties(), indicatorAccessory: indicatorAccessory)
        }
    }
    
    enum CategoryCellType {
        case category(DiscussionCategoryModel?)
        case subCategory(DiscussionCategoryModel?)
        
        var cellModel: TextCellViewModel {
            return CategoryCellViewModel(self, indicatorAccessory: true)
        }
        
        var selectTitle: String {
            switch self {
            case .category(let category):
                return category?.name ?? "Select category *"
            case .subCategory(let category):
                return category?.name ?? "Select sub-category"
            }
        }
    }
    
    fileprivate func updateData(_ categories: [DiscussionCategoryModel]) {
        self.categories.accept(categories)
    }
    
    fileprivate func prepareCells() -> [CellViewModel] {
        var items: [CategoryCellType] = [.category(self.selectedCategory.value)]
        if let category = self.selectedCategory.value, category.sub != nil && !category.sub!.isEmpty {
            items.append(.subCategory(self.selectedSubCategory.value))
        }
        return items.map { $0.cellModel }
    }
    
    fileprivate func prepareOpenSelectCategory(_ categories: [DiscussionCategoryModel], selected: DiscussionCategoryModel?) {
        let selectCategoryViewModel = SelectCategoryViewModel(categories)
        
        selectCategoryViewModel.shouldSelectCategory
            .`do`(onNext: { [unowned self] category in
                if category.name != self.selectedSubCategory.value?.name {
                    self.selectedSubCategory.accept(nil)
                }
            })
            ~> self.selectedCategory
            ~ selectCategoryViewModel.disposeBag
        
        self.shouldPresent(.selectCategoryController(title: "Select Category", viewModel: selectCategoryViewModel))
    }
    
    fileprivate func prepareOpenSelectSubCategory(_ categories: [DiscussionCategoryModel], selected: DiscussionCategoryModel?) {
        let selectCategoryViewModel = SelectCategoryViewModel(categories)
        
        selectCategoryViewModel.shouldSelectCategory
            ~> self.selectedSubCategory
            ~ selectCategoryViewModel.disposeBag
        
        self.shouldPresent(.selectCategoryController(title: "Select Sub-Category", viewModel: selectCategoryViewModel))
    }
}

// MARK: - Action Handlers
fileprivate extension CreatePostViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? CategoryCellViewModel {
            switch item.category {
            case .category(let category):
                self.prepareOpenSelectCategory(self.categories.value, selected: category)
            case .subCategory(let category):
                if let sub = self.selectedCategory.value?.sub {
                    self.prepareOpenSelectSubCategory(sub, selected: category)
                }
            }
        }
    }
}

// MARK: - SetUp RxObservers
extension CreatePostViewModel {
    
    func setUpRxObservers() {
        setUpContentObservers()
        setUpActionObservers()
    }
    
    func setUpContentObservers() {
        self.selectedCategory.asObservable()
            .map { [unowned self] _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.selectedSubCategory.asObservable()
            .map { [unowned self] _ in self.prepareCells() }
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

// MARK: - Post Creation Type
enum SubmitPostType {
    
    case edit(PostModel)
    case create
}
