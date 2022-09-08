//
//  CreatePostViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 3/23/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RichEditorView
import MaterialComponents
import RxKeyboard
import Kingfisher
import RxKingfisher

class CreatePostViewController: BaseViewController, KeyboardController, LoadingIndicatorController, AlertDialogController {
    
    fileprivate lazy var keyboardDisposeBag = DisposeBag()

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: PaddingTextField!
    @IBOutlet weak var richEditorView: SRichEditorView!
    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var uploadThumbnailButton: CenteredImageButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    let minContentHeight: CGFloat = 200
    var isFirstInitial: Bool = false
    
    private lazy var imagePickerHelper: MediaPickerHelper = { [unowned self] in
        return MediaPickerHelper(withPresenting: self)
    }()
    
    lazy var closeButton: UIBarButtonItem = {
        return UIBarButtonItem(image: R.image.clearIcon(), style: .plain, target: nil, action: nil)
    }()
    lazy var postButton: UIBarButtonItem = { [unowned self] in
        return UIBarButtonItem(title: self.viewModel.postTitle, style: .plain, target: nil, action: nil)
    }()
    
    lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 54))
        toolbar.options = CRichEditorOption.all
        toolbar.tintColor = UIColor.black
        return toolbar
    }()
    
    var viewModel: CreatePostViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
        viewModel.downloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.keyboardDisposeBag = DisposeBag()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setUpKeyboardObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.title = self.viewModel.titleText
        self.richEditorView.placeholder = R.string.post.articleBody.localized()
    }
}

// MARK: - Preparations & Tools
extension CreatePostViewController {
    
    func setUpViews() {
        self.titleTextField.addBorders(edges: [.bottom], color: .color(.border))
        self.richEditorView.addBorders(edges: [.bottom], color: .color(.border))
        
        setUpEditorView(self.richEditorView)
        
        self.navigationItem.rightBarButtonItem = self.postButton
        self.navigationItem.leftBarButtonItem = self.closeButton
        self.prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.separatorColor = .color(.border)
        self.tableView.tableFooterView = UIView()
        self.tableView.register(TextTableViewCell.self)
    }
    
    func setUpEditorView(_ editorView: RichEditorView) {
        editorView.isScrollEnabled = false
        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
        editorView.editorMargin = 16
        
        self.toolbar.delegate = self
        self.toolbar.editor = editorView
        
        editorView.webView.scrollView.contentSize.height = editorView.frame.height
    }
}

// MARK: - RichEditorView Delegate
extension CreatePostViewController: RichEditorDelegate, RichEditorToolbarDelegate {
    
    func richEditorDidLoad(_ editor: RichEditorView) {
        editor.editorMargin = 16
        editor.customCssAndJS()
        editor.setFontSize(14)
        let html = editor.html
        editor.html = html
        self.isFirstInitial = true
    }
    
    func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
        UIView.setAnimationsEnabled(false)
        self.contentHeightConstraint.constant = (CGFloat(height) >= self.minContentHeight) ? CGFloat(height) : self.minContentHeight
        if isFirstInitial {
            let frame = self.richEditorView.frame
            let y = CGFloat(height) < self.minContentHeight ? CGFloat(height) : (frame.height - 100)
            let rectToScroll = CGRect(x: 0, y: y, width: frame.width, height: 200)
            self.scrollView.scrollRectToVisible(rectToScroll, animated: false)
        }
        UIView.setAnimationsEnabled(true)
    }
    
    func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool {
        return false
    }
    
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        self.viewModel.descriptionFieldViewModel.value = content
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
        self.viewModel.didAction(with: .chooseImage(.insertImage))
    }
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
    }
}

// MARK: - SetUp RxObservers
extension CreatePostViewController {
    
    func setUpRxObservers() {
        setUpControlsObservers()
        setUpContentChangedObservers()
        setUpShouldPresentObservers()
        setUpShouldPresentErrorObsevers()
        setUpTabSelfToDismissKeyboard()?.disposed(by: self.disposeBag)
    }
    
    func setUpControlsObservers() {
        self.uploadThumbnailButton.rx.tap.asObservable()
            .map { CreatePostViewModel.Action.chooseImage(.thumbnail) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.imagePickerHelper.selectedPhotoSubject.asObservable()
            .map { CreatePostViewModel.Action.imageSelected($0.first!) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.postButton.rx.tap
            .map { CreatePostViewModel.Action.postPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.closeButton.rx.tap
            .map { CreatePostViewModel.Action.closePressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items) { tableView, index, item in
                switch item {
                case is TextCellViewModel:
                    let cell: TextTableViewCell = tableView.dequeueReusableCell(forIndexPath: IndexPath(row: index, section: 0))
                    cell.cellModel = item as? TextCellViewModel
                    return cell
                default:
                    return UITableViewCell()
                }
            } ~ self.disposeBag
        
        // Item Selected
        self.tableView.rx.itemSelected.asObservable()
            .`do`(onNext: { [weak self] indexPath in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            })
            .map { CreatePostViewModel.Action.itemSelected($0) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.viewModel.thumbnailImage.asObservable()
            .filter { $0 != nil }
            ~> self.thumbnailImageView.rx.image
            ~ self.disposeBag
        
        self.viewModel.shouldInsertImage.asObservable()
            .subscribe(onNext: { [weak self] url in
                self?.richEditorView.insertImage(url, alt: "")
            }) ~ self.disposeBag
        
        self.viewModel.shouldEnablePost ~> self.postButton.rx.isEnabled ~ self.disposeBag
        self.viewModel.titleTextFieldViewModel.bind(with: self.titleTextField)
        self.viewModel.descriptionFieldViewModel.textFieldText.take(1)
            .bind(to: self.richEditorView.rx.html)
            ~ self.disposeBag
        
        self.viewModel.thumbnialUrl.asObservable()
            .filter { $0 != nil }
            .map { $0 }
            .bind(to: self.thumbnailImageView.kf.rx.image())
            ~ self.disposeBag
        
        self.viewModel.addThumbnailState.asObservable()
            .subscribe(onNext: { [weak self] data in
                self?.uploadThumbnailButton.setTitle(data.0, for: .normal)
                self?.uploadThumbnailButton.setImage(data.1, for: .normal)
            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [unowned self] viewToPresent in
                switch viewToPresent {
                case .loading(let loading):
                    loading ? self.showLoading() : self.dismissLoading()
                case .selectCategoryController(let title, let viewModel):
                    let listTableViewController = ListTableViewController(viewModel)
                    listTableViewController.title = title
                    listTableViewController.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 8, right: 0)
                    let bottomSheet = BottomSheetListViewController(contentViewController: listTableViewController)
                    self.present(bottomSheet, animated: true, completion: nil)
                case .chooseMediaController(let title, _):
                    self.imagePickerHelper.singleSelect = true
                    self.imagePickerHelper.showImagePickerAlert(title: title)
                case .dismiss:
                    self.dismiss(animated: true, completion: nil)
                case .showAlertDialogController(let alertDialogModel):
                    self.showDialog(alertDialogModel)
                }
            }) ~ self.disposeBag
    }
    
    func setUpShouldPresentErrorObsevers() {
        self.viewModel.shouldPresentError.asObservable()
            .subscribe(onNext: { [unowned self] errorInfo in
                self.showDialogError(errorInfo, positiveButton: R.string.common.confirm.localized(), positiveCompletion: nil)
            }).disposed(by: self.disposeBag)
    }
    
    func setUpKeyboardObservers() {
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardHeight in
                if let _self = self {
                    _self.bottomConstraint.constant = keyboardHeight
                    UIView.animate(withDuration: 0.3, animations: {
                        _self.view.layoutIfNeeded()
                    })
                }
            }).disposed(by: self.keyboardDisposeBag)
    }
}
