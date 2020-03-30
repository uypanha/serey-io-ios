//
//  CreatePostViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 3/23/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RichEditorView

class CreatePostViewController: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: PaddingTextField!
    @IBOutlet weak var richEditorView: SRichEditorView!
    @IBOutlet weak var shortDescTextField: PaddingTextField!
    @IBOutlet weak var tableView: ContentSizedTableView!
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    
    let minContentHeight: CGFloat = 200
    var isFirstInitial: Bool = false
    
    lazy var postButton: UIBarButtonItem = { [unowned self] in
        return UIBarButtonItem(title: "Post", style: .plain, target: nil, action: nil)
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
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.title = "Post an Article"
        self.richEditorView.placeholder = "Article body"
    }
}

// MARK: - Preparations & Tools
extension CreatePostViewController {
    
    func setUpViews() {
        self.titleTextField.addBorders(edges: [.bottom], color: ColorName.border.color)
        self.richEditorView.addBorders(edges: [.bottom], color: ColorName.border.color)
        self.shortDescTextField.addBorders(edges: [.bottom], color: ColorName.border.color)
        
        setUpEditorView(self.richEditorView)
        
        self.navigationItem.rightBarButtonItem = self.postButton
        self.prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.separatorColor = ColorName.border.color
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
        if CGFloat(height) != self.contentHeightConstraint.constant {
            UIView.setAnimationsEnabled(false)
            self.contentHeightConstraint.constant = (CGFloat(height) >= self.minContentHeight) ? CGFloat(height) : self.minContentHeight
            if isFirstInitial {
                let frame = self.richEditorView.frame
                let rectToScroll = CGRect(x: 0, y: frame.height - 20, width: frame.width, height: frame.height)
                self.scrollView.scrollRectToVisible(rectToScroll, animated: false)
            }
            UIView.setAnimationsEnabled(true)
        }
    }
    
    func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool {
        return false
    }
    
    func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar) {
    }
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
    }
}

// MARK: - SetUp RxObservers
extension CreatePostViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpShouldPresentObservers()
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
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [unowned self] viewToPresent in
                switch viewToPresent {
                case .selectCategoryController(let data):
                    let listTableViewController = ListTableViewController(data.viewModel)
                    listTableViewController.title = data.title
                    self.show(listTableViewController, sender: nil)
                }
            }) ~ self.disposeBag
    }
}
