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
        case chooseImage(MediaChooserType)
        case imageSelected(PickerPhotoModel)
        case postPressed
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case selectCategoryController(title: String, viewModel: SelectCategoryViewModel)
        case chooseMediaController(title: String, editable: Bool)
        case dismiss
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    var imageType: MediaChooserType? = nil
    
    let cells: BehaviorRelay<[CellViewModel]>
    let post: BehaviorRelay<PostModel?>
    let categories: BehaviorRelay<[DiscussionCategoryModel]>
    let selectedCategory: BehaviorRelay<DiscussionCategoryModel?>
    let selectedSubCategory: BehaviorRelay<DiscussionCategoryModel?>
    let newThumbnailImage: BehaviorRelay<PickerPhotoModel?>
    
    let titleTextFieldViewModel: TextFieldViewModel
    let descriptionFieldViewModel: TextFieldViewModel
    let shortDescriptionFieldViewModel: TextFieldViewModel
    let thumbnialUrl: BehaviorRelay<URL?>
    
    let shouldInsertImage: PublishSubject<String>
    let shouldEnablePost: BehaviorSubject<Bool>
    let addThumbnailState: BehaviorSubject<(String?, UIImage?)>
    
    let discussionService: DiscussionService
    let fileUploadService: FileUploadService
    let isDownloading: BehaviorRelay<Bool>
    
    let titleText: String!
    let postTitle: String!
    
    init(_ type: SubmitPostType) {
        self.post = BehaviorRelay(value: type.postModel)
        self.titleText = type.pageTitle
        self.postTitle = type.postTitle
        self.cells = BehaviorRelay(value: [])
        self.categories = BehaviorRelay(value: [])
        self.selectedCategory = BehaviorRelay(value: nil)
        self.selectedSubCategory = BehaviorRelay(value: nil)
        self.newThumbnailImage = BehaviorRelay(value: nil)
        
        self.titleTextFieldViewModel = TextFieldViewModel.textFieldWith(title: R.string.post.enterTitle.localized(), errorMessage: nil, validation: .notEmpty)
        self.descriptionFieldViewModel = TextFieldViewModel.textFieldWith(title: R.string.post.articleBody.localized(), errorMessage: "", validation: .notEmpty)
        self.shortDescriptionFieldViewModel = TextFieldViewModel.textFieldWith(title: R.string.post.shortDescription.localized(), errorMessage: "", validation: .none)
        self.thumbnialUrl = BehaviorRelay(value: nil)
        
        self.shouldInsertImage = PublishSubject()
        self.shouldEnablePost = BehaviorSubject(value: false)
        self.addThumbnailState = BehaviorSubject(value: ("Upload Thumbnail", R.image.bigPlusIcon()))
        
        self.discussionService = DiscussionService()
        self.fileUploadService = FileUploadService()
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
    
    private func uploadImage(_ image: UIImage) -> Observable<FileUploadModel> {
        return self.fileUploadService.uploadPhoto(image)
    }
    
    private func submitPost(with thumnailUrl: String) {
        let submitModel = self.prepareSubmitModel(with: thumnailUrl)
        self.discussionService.submitPost(submitModel)
            .subscribe(onNext: { [weak self] data in
                NotificationDispatcher.sharedInstance.dispatch(.postSubmitted)
                self?.shouldPresent(.loading(false))
                self?.shouldPresent(.dismiss)
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
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
                return category?.name ?? "\(R.string.post.selectCategory.localized()) *"
            case .subCategory(let category):
                return category?.name ?? R.string.post.selectSubCategory.localized()
            }
        }
    }
    
    fileprivate func notifyDataToUpdate(_ data: PostModel) {
        self.titleTextFieldViewModel.value = data.title
        self.descriptionFieldViewModel.value = data.description
        self.shortDescriptionFieldViewModel.value = data.shortDesc
        self.thumbnialUrl.accept(data.firstThumnailURL)
        if data.categoryItem.count > 0 {
            self.selectedCategory.accept(DiscussionCategoryModel(name: (data.categoryItem.first ?? "").capitalized, sub: nil))
            if data.categoryItem.count > 1 {
                self.selectedSubCategory.accept(DiscussionCategoryModel(name: data.categoryItem[1].capitalized, sub: nil))
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
        
        self.shouldPresent(.selectCategoryController(title: R.string.post.selectCategory.localized(), viewModel: selectCategoryViewModel))
    }
    
    fileprivate func prepareOpenSelectSubCategory(_ categories: [DiscussionCategoryModel], selected: DiscussionCategoryModel?) {
        let selectCategoryViewModel = SelectCategoryViewModel(categories)
        
        selectCategoryViewModel.shouldSelectCategory
            ~> self.selectedSubCategory
            ~ selectCategoryViewModel.disposeBag
        
        self.shouldPresent(.selectCategoryController(title: R.string.post.selectSubCategory.localized(), viewModel: selectCategoryViewModel))
    }
    
    fileprivate func validateThumbnail(_ completion: @escaping (String) -> Void) {
        if let newThumnail = self.newThumbnailImage.value {
            self.uploadImage(newThumnail.image)
                .subscribe(onNext: { data in
                    completion(data.url)
                }, onError: { [weak self] error in
                    self?.shouldPresent(.loading(false))
                    let errorInfo = ErrorHelper.prepareError(error: error)
                    self?.shouldPresentError(errorInfo)
                }) ~ self.disposeBag
        } else if let post = self.post.value {
            completion(post.firstThumnailURL?.absoluteString ?? "")
        } else {
            completion("")
        }
    }
    
    fileprivate func prepareSubmitModel(with thumbnailUrl: String) -> SubmitPostModel {
        let permlink = self.post.value?.permlink
        let title = self.titleTextFieldViewModel.value ?? ""
        let body = self.descriptionFieldViewModel.value ?? ""
        let shortDesc = self.shortDescriptionFieldViewModel.value ?? ""
        let category = self.selectedCategory.value?.name ?? ""
        let subCategory = self.selectedSubCategory.value?.name ?? ""
        return SubmitPostModel(permlink: permlink, title: title, shortDesc: shortDesc, body: body, categories: category, subcategories: [subCategory], images: [thumbnailUrl])
    }
    
    fileprivate func determineUploadThumbnailState() {
        let selectedImage = (self.thumbnialUrl.value != nil || self.newThumbnailImage.value != nil)
        let title = selectedImage ? "Change Thumbnail" : "Upload Thubmnail"
        let image = selectedImage ? R.image.bigEditIcon() : R.image.bigPlusIcon()
        self.addThumbnailState.onNext((title, image))
    }
    
    func validateForm() -> Bool {
        return self.titleTextFieldViewModel.validate()
            && self.descriptionFieldViewModel.validate()
            && self.shortDescriptionFieldViewModel.validate()
            && self.selectedCategory.value != nil
            && (self.newThumbnailImage.value != nil || self.thumbnialUrl.value != nil)
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
    
    func handleImageSelected(_ photoModel: PickerPhotoModel) {
        if let imageType = self.imageType {
            switch imageType {
            case .thumbnail:
                self.newThumbnailImage.accept(photoModel)
            case .insertImage:
                self.shouldPresent(.loading(true))
                self.uploadImage(photoModel.image)
                    .subscribe(onNext: { [weak self] data in
                        self?.shouldPresent(.loading(false))
                        self?.shouldInsertImage.onNext(data.url)
                    }, onError: { [weak self] error in
                        self?.shouldPresent(.loading(false))
                    }) ~ self.disposeBag
            }
        }
    }
    
    func handleChooseImage(with type: MediaChooserType) {
        self.imageType = type
        self.shouldPresent(.chooseMediaController(title: type.title, editable: false))
    }
    
    func handlePostPressed() {
        if self.validateForm() {
            self.shouldPresent(.loading(true))
            self.validateThumbnail { url in
                self.submitPost(with: url)
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
        self.post.asObservable()
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] data in
                self?.notifyDataToUpdate(data!)
            }) ~ self.disposeBag
        
        self.selectedCategory.asObservable()
            .`do`(onNext: { [unowned self] _ in
                self.shouldEnablePost.onNext(self.validateForm())
            })
            .map { [unowned self] _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.selectedSubCategory.asObservable()
            .map { [unowned self] _ in self.prepareCells() }
            ~> self.cells
            ~ self.disposeBag
        
        self.titleTextFieldViewModel.textFieldText
            .map { _ in self.validateForm() }
            ~> self.shouldEnablePost
            ~ self.disposeBag
        
        self.descriptionFieldViewModel.textFieldText
            .map { _ in self.validateForm() }
            ~> self.shouldEnablePost
            ~ self.disposeBag
        
        self.newThumbnailImage
            .`do`(onNext: { [weak self] _ in
                self?.determineUploadThumbnailState()
            })
            .map { _ in self.validateForm() }
            ~> self.shouldEnablePost
            ~ self.disposeBag
        
        self.thumbnialUrl
            .subscribe(onNext: { [weak self] _ in
                self?.determineUploadThumbnailState()
            }) ~ self.disposeBag
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .itemSelected(let indexPath):
                    self?.handleItemSelected(indexPath)
                case .chooseImage(let imageType):
                    self?.handleChooseImage(with: imageType)
                case .imageSelected(let photoModel):
                    self?.handleImageSelected(photoModel)
                case .postPressed:
                    self?.handlePostPressed()
                }
            }) ~ self.disposeBag
    }
}

// MARK: - Post Creation Type
enum SubmitPostType {
    
    case edit(PostModel)
    case create
    
    var postModel: PostModel? {
        switch self {
        case .edit(let postModel):
            return postModel
        default:
            return nil
        }
    }
    
    var pageTitle: String {
        switch self {
        case .create:
            return R.string.post.postAnArticle.localized()
        default:
            return R.string.post.updateAnArticle.localized()
        }
    }
    
    var postTitle: String {
        switch self {
        case .create:
            return R.string.post.post.localized()
        default:
            return R.string.common.update.localized()
        }
    }
}

// MARK: -
enum MediaChooserType {
    case thumbnail
    case insertImage
    
    var title: String {
        switch self {
        case .thumbnail:
            return R.string.post.chooseThumbnail.localized()
        case .insertImage:
            return R.string.post.insertImageWith.localized()
        }
    }
}
