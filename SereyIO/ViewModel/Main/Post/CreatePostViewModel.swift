//
//  CreatePostViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 3/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RealmSwift

class CreatePostViewModel: BaseCellViewModel, CollectionSingleSecitionProviderModel, ShouldReactToAction, ShouldPresent, DownloadStateNetworkProtocol {
    
    enum Action {
        case itemSelected(IndexPath)
        case chooseImage(MediaChooserType)
        case imageSelected(PickerPhotoModel)
        case closePressed
        case postPressed
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case selectCategoryController(title: String, viewModel: SelectCategoryViewModel)
        case chooseMediaController(title: String, editable: Bool)
        case showAlertDialogController(AlertDialogModel)
        case dismiss
    }
    
    // input:
    lazy var didActionSubject = PublishSubject<Action>()
    
    // output:
    lazy var shouldPresentSubject = PublishSubject<ViewToPresent>()
    
    var imageType: MediaChooserType? = nil
    
    let cells: BehaviorRelay<[CellViewModel]>
    let submitType: BehaviorRelay<SubmitPostType>
    let post: BehaviorRelay<PostModel?>
    let draft: BehaviorRelay<DraftModel?>
    
    let categories: BehaviorRelay<[DiscussionCategoryModel]>
    let selectedCategory: BehaviorRelay<DiscussionCategoryModel?>
    let selectedSubCategory: BehaviorRelay<DiscussionCategoryModel?>
    
    let titleTextFieldViewModel: TextFieldViewModel
    let descriptionFieldViewModel: TextFieldViewModel
    let shortDescriptionFieldViewModel: TextFieldViewModel
    let thumbnialUrl: BehaviorRelay<URL?>
    let thumbnailImage: BehaviorRelay<UIImage?>
    
    let shouldInsertImage: PublishSubject<String>
    let shouldEnablePost: BehaviorSubject<Bool>
    let addThumbnailState: BehaviorSubject<(String?, UIImage?)>
    
    let discussionService: DiscussionService
    let fileUploadService: FileUploadService
    let isDownloading: BehaviorRelay<Bool>
    
    let titleText: String!
    let postTitle: String!
    
    init(_ type: SubmitPostType) {
        self.submitType = .init(value: type)
        self.post = .init(value: type.postModel)
        self.draft = .init(value: type.draftModel)
        self.titleText = type.pageTitle
        self.postTitle = type.postTitle
        self.cells = .init(value: [])
        self.categories = .init(value: [])
        self.selectedCategory = .init(value: nil)
        self.selectedSubCategory = .init(value: nil)
        
        self.titleTextFieldViewModel = .textFieldWith(title: R.string.post.enterTitle.localized(), errorMessage: nil, validation: .notEmpty)
        self.descriptionFieldViewModel = .textFieldWith(title: R.string.post.articleBody.localized(), errorMessage: "", validation: .notEmpty)
        self.shortDescriptionFieldViewModel = .textFieldWith(title: R.string.post.shortDescription.localized(), errorMessage: "", validation: .none)
        self.thumbnialUrl = .init(value: nil)
        self.thumbnailImage = .init(value: nil)
        
        self.shouldInsertImage = .init()
        self.shouldEnablePost = .init(value: false)
        self.addThumbnailState = .init(value: ("Upload Thumbnail", R.image.bigPlusIcon()))
        
        self.discussionService = .init()
        self.fileUploadService = .init()
        self.isDownloading = .init(value: false)
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
    
    private func fetchPostDetial() {
        if let post = self.post.value {
            self.discussionService.getPostDetail(permlink: post.permlink, authorName: post.authorName)
                .subscribe(onNext: { [weak self] response in
                    NotificationDispatcher.sharedInstance.dispatch(.postUpdated(permlink: post.permlink, author: post.authorName, post: response.content))
                    self?.shouldPresent(.loading(false))
                    self?.shouldPresent(.dismiss)
                }, onError: { [weak self] error in
                    NotificationDispatcher.sharedInstance.dispatch(.postUpdated(permlink: post.permlink, author: post.authorName, post: nil))
                    self?.shouldPresent(.loading(false))
                    self?.shouldPresent(.dismiss)
                }) ~ self.disposeBag
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
            .subscribe(onNext: { [weak self] _ in
                self?.handlePostSubmitted()
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparations & Tools
extension CreatePostViewModel {
    
    class SelectCategoryCellViewModel: TextCellViewModel {
        
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
            return SelectCategoryCellViewModel(self, indicatorAccessory: true)
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
            var selectedCategory = DiscussionCategoryModel(name: (data.categoryItem.first ?? "").capitalized, sub: nil)
            if data.categoryItem.count > 1 {
                let subCategory = DiscussionCategoryModel(name: data.categoryItem[1].capitalized, sub: nil)
                selectedCategory.sub = [subCategory]
                self.selectedSubCategory.accept(subCategory)
            }
            self.selectedCategory.accept(selectedCategory)
        }
    }
    
    fileprivate func notifyDateDraft(_ data: DraftModel) {
        self.titleTextFieldViewModel.value = data.title
        self.descriptionFieldViewModel.value = data.descriptionText
        self.shortDescriptionFieldViewModel.value = data.shortDescription
        self.thumbnialUrl.accept(data.imageURL)
        self.thumbnailImage.accept(data.image)
        if data.categoryItem.count > 0 {
            var selectedCategory = DiscussionCategoryModel(name: (data.categoryItem.first ?? "").capitalized, sub: nil)
            if data.categoryItem.count > 1 {
                let subCategory = DiscussionCategoryModel(name: data.categoryItem[1].capitalized, sub: nil)
                selectedCategory.sub = [subCategory]
                self.selectedSubCategory.accept(subCategory)
            }
            self.selectedCategory.accept(selectedCategory)
        }
    }
    
    fileprivate func updateData(_ categories: [DiscussionCategoryModel]) {
        if let selectedCategory = self.selectedCategory.value {
            let first = categories.first { category -> Bool in
                return selectedCategory.name == category.name
            }
            self.selectedCategory.accept(first)
        }
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
        if let newThumnail = self.thumbnailImage.value {
            self.uploadImage(newThumnail)
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
        var subCategories: [String] = []
        if let subCategory = self.selectedSubCategory.value?.name {
            subCategories.append(subCategory)
        }
        return SubmitPostModel(permlink: permlink, title: title, shortDesc: shortDesc, body: body, categories: category, subcategories: subCategories, images: [thumbnailUrl])
    }
    
    fileprivate func determineUploadThumbnailState() {
        let selectedImage = (self.thumbnialUrl.value != nil || self.thumbnailImage.value != nil)
        let title = selectedImage ? R.string.post.changeThumbnail : R.string.post.uploadThumbnail
        let image = selectedImage ? R.image.bigEditIcon() : R.image.bigPlusIcon()
        self.addThumbnailState.onNext((title.localized(), image))
    }
    
    func validateForm() -> Bool {
        return self.titleTextFieldViewModel.validate()
            && self.descriptionFieldViewModel.validate()
            && self.shortDescriptionFieldViewModel.validate()
            && self.selectedCategory.value != nil
            && (self.thumbnailImage.value != nil || self.thumbnialUrl.value != nil)
    }
    
    func isFilledSomeInfo() -> Bool {
        return self.titleTextFieldViewModel.validate()
            || self.descriptionFieldViewModel.validate()
            || self.shortDescriptionFieldViewModel.validate(validation: .notEmpty)
            || self.selectedCategory.value != nil
            || self.thumbnailImage.value != nil
            || self.thumbnialUrl.value != nil
    }
    
    private func generateDraftId() -> Int {
        let date = Date()
        let timeInterval = date.timeIntervalSince1970
        return Int(timeInterval)
    }
}

// MARK: - Action Handlers
fileprivate extension CreatePostViewModel {
    
    func handleItemSelected(_ indexPath: IndexPath) {
        if let item = self.item(at: indexPath) as? SelectCategoryCellViewModel {
            switch item.category {
            case .category(let category):
                switch self.submitType.value {
                case .create, .draft:
                    self.prepareOpenSelectCategory(self.categories.value, selected: category)
                default:
                    break
                }
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
                self.thumbnailImage.accept(photoModel.image)
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
    
    func handlePostSubmitted() {
        if self.post.value != nil {
            // must be updated post
            fetchPostDetial()
        } else {
            NotificationDispatcher.sharedInstance.dispatch(.postCreated)
            self.shouldPresent(.loading(false))
            self.shouldPresent(.dismiss)
            
            if let draft = self.draft.value {
                RealmManager.delete(draft)
            }
        }
    }
    
    func handleClosePressed() {
        if self.isFilledSomeInfo() && self.post.value == nil {
            let yesAction = ActionModel("Yes, please", style: .default) {
                self.handleSaveDraft()
            }
            
            let cancelAction = ActionModel(R.string.common.no.localized(), style: .cancel) {
                self.shouldPresent(.dismiss)
            }
            let alertDialogModel = AlertDialogModel(title: "Unfinished article", message: "You’re about to leave the unfinsihed article.\nDo you wish to save it as a draft?", actions: [yesAction, cancelAction])
            self.shouldPresent(.showAlertDialogController(alertDialogModel))
        } else {
            self.shouldPresent(.dismiss)
        }
    }
    
    func handleSaveDraft() {
        let id: Int = self.draft.value?.id ?? self.generateDraftId()
        let draftModel = DraftModel(id)
        draftModel.title = self.titleTextFieldViewModel.value
        draftModel.descriptionText = self.descriptionFieldViewModel.value
        draftModel.shortDescription = self.shortDescriptionFieldViewModel.value
        draftModel.imageData = self.thumbnailImage.value?.jpegData(compressionQuality: 0.5)
        draftModel.imageUrl = self.thumbnialUrl.value?.absoluteString
        var categories: [String] = []
        if let category = self.selectedCategory.value?.name {
            categories.append(category)
            if let subCategory = self.selectedSubCategory.value?.name {
                categories.append(subCategory)
            }
        }
        draftModel.categoryItem.removeAll()
        draftModel.categoryItem.append(objectsIn: categories)
        draftModel.save()
        self.shouldPresent(.dismiss)
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
        
        self.thumbnailImage
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
        
        self.post.asObservable()
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] data in
                self?.notifyDataToUpdate(data!)
            }) ~ self.disposeBag
        
        self.draft.asObservable()
            .filter { $0 != nil }
            .subscribe(onNext: { [weak self] draft in
                self?.notifyDateDraft(draft!)
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
                case .closePressed:
                    self?.handleClosePressed()
                }
            }) ~ self.disposeBag
    }
}

// MARK: - Post Creation Type
enum SubmitPostType {
    
    case edit(PostModel)
    case draft(DraftModel)
    case create
    
    var postModel: PostModel? {
        switch self {
        case .edit(let postModel):
            return postModel
        default:
            return nil
        }
    }
    
    var draftModel: DraftModel? {
        switch self {
        case .draft(let draft):
            return draft
        default:
            return nil
        }
    }
    
    var pageTitle: String {
        switch self {
        case .create, .draft:
            return R.string.post.postAnArticle.localized()
        default:
            return R.string.post.updateAnArticle.localized()
        }
    }
    
    var postTitle: String {
        switch self {
        case .create, .draft:
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
            return R.string.post.chooseThumbnailWith.localized()
        case .insertImage:
            return R.string.post.insertImageWith.localized()
        }
    }
}
