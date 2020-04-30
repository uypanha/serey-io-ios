//
//  CommentsListViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/25/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class CommentsListViewModel: BaseListTableViewModel, ShouldRefreshProtocol {
    
    let username: BehaviorRelay<String>
    let type: BehaviorRelay<GetCommentType>
    let comments: BehaviorRelay<[CommentReplyModel]>
    
    let discussionService: DiscussionService
    
    init(_ username: String, with type: GetCommentType) {
        self.username = BehaviorRelay(value: username)
        self.type = BehaviorRelay(value: type)
        self.comments = BehaviorRelay(value: [])
        self.discussionService = DiscussionService()
        super.init([], false)
        
        setUpRxObservers()
    }
    
    override func downloadData() {
        if !self.isDownloading.value {
            fetchCommentList()
            self.comments.renotify()
        }
    }
    
    func shouldRefreshData() {
        self.downloadData()
    }
    
    override func registerTableViewCell(_ tableView: UITableView) {
        tableView.register(UserCommentReplyTableViewCell.self)
    }
    
    override func configureCell(_ datasource: TableViewSectionedDataSource<SectionItem>, _ tableView: UITableView, _ indexPath: IndexPath, _ item: CellViewModel) -> UITableViewCell {
        switch item {
        case is UserCommentReplyCellViewModel:
            let cell: UserCommentReplyTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
            cell.cellModel = item as? UserCommentReplyCellViewModel
            return cell
        default:
            return super.configureCell(datasource, tableView, indexPath, item)
        }
    }
}

// MARK: - Networks
extension CommentsListViewModel {
    
    func fetchCommentList() {
        self.isDownloading.accept(true)
        self.discussionService.getCommentsReply(of: username.value, type: type.value)
            .subscribe(onNext: { [weak self] data in
                self?.isDownloading.accept(false)
                self?.comments.accept(data.data)
            }, onError: { [weak self] error in
                self?.isDownloading.accept(false)
                self?.comments.renotify()
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Preparatations & Tools
extension CommentsListViewModel {
    
    func prepareCells(_ comments: [CommentReplyModel]) -> [SectionItem] {
        var cells: [CellViewModel] = comments.map { UserCommentReplyCellViewModel($0) }
        if cells.isEmpty && self.isDownloading.value {
            cells.append(contentsOf: (0...4).map { _ in UserCommentReplyCellViewModel(true) })
        }
        return [SectionItem(items: cells)]
    }
    
    func prepareEmptyViewModel() -> EmptyOrErrorViewModel {
        let title = "No activities found"
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withEmptyTitle: title, emptyDescription: "", iconImage: R.image.emptyActivities()))
    }
    
    open func prepareEmptyViewModel(_ erroInfo: ErrorInfo) -> EmptyOrErrorViewModel {
        return EmptyOrErrorViewModel(withErrorEmptyModel: EmptyOrErrorModel(withErrorInfo: erroInfo, actionTitle: R.string.common.tryAgain.localized(), actionCompletion: { [unowned self] in
            self.downloadData()
        }))
    }
}

// MARK: - SetUp Rx Observers
extension CommentsListViewModel {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.comments.asObservable()
            .map { self.prepareCells($0) }
            ~> self.cells
            ~ self.disposeBag
        
        self.comments.asObservable()
            .subscribe(onNext: { [unowned self] comments in
                if comments.isEmpty && !self.isDownloading.value {
                    self.emptyOrError.onNext(self.prepareEmptyViewModel())
                }
            }) ~ self.disposeBag
    }
}
