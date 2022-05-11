//
//  EnterIssueViewModel.swift
//  SereyIO
//
//  Created by Mäd on 03/02/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class EnterIssueViewModel: BaseViewModel, ShouldPresent, ShouldReactToAction {
    
    enum Action {
        case reportPressed
    }
    
    enum ViewToPresent {
        case loading(Bool)
        case confirmDialogController(viewModel: ConfirmDialogViewModel, dismissable: Bool = true)
        case dismiss
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let postId: String
    let type: ReportTypeModel
    let issueTextFieldViewModel: TextFieldViewModel
    
    let discussionService: DiscussionService
    
    init(from postId: String, with type: ReportTypeModel) {
        self.postId = postId
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.type = type
        self.issueTextFieldViewModel = .textFieldWith(title: "Problem", placeholder: "State your issue here", errorMessage: "Please enter your issue", validation: .notEmpty)
        self.discussionService = .init()
        super.init()
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension EnterIssueViewModel {
    
    func reportPost(_ description: String) {
        self.shouldPresent(.loading(true))
        self.discussionService.reportPost(self.postId, typeId: self.type.id, description: description)
            .subscribe(onNext: { [weak self] data in
                self?.shouldPresent(.loading(false))
                self?.handleReportSuccess()
            }, onError: { [weak self] error in
                self?.shouldPresent(.loading(false))
                self?.shouldPresentError(ErrorHelper.prepareError(error: error))
            }) ~ self.disposeBag
    }
}

// MARK: - Action Handlers
extension EnterIssueViewModel {
    
    func handleReportPressed() {
        if self.issueTextFieldViewModel.validate() {
            let message = "Are you sure to report this post as \"\(self.issueTextFieldViewModel.value ?? "")\"?"
            let action = ActionModel("Submit", style: .default) {
                self.reportPost(self.issueTextFieldViewModel.value ?? "")
            }
            let viewModel = ConfirmDialogViewModel(icon: R.image.infoYellowIcon(), title: "Report this post?", message: message, action: action)
            self.shouldPresent(.confirmDialogController(viewModel: viewModel))
        }
    }
    
    func handleReportSuccess() {
        let message = "We’ll use this information to improve our process. Independent fact-checkers may review the article."
        let action = ActionModel("Done", style: .default) {
            self.shouldPresent(.dismiss)
        }
        let viewModel = ConfirmDialogViewModel(title: "Thanks for letting us know.", message: message, action: action)
        self.shouldPresent(.confirmDialogController(viewModel: viewModel, dismissable: false))
    }
}

// MARK: - SetUp RxObservers
extension EnterIssueViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .reportPressed:
                    self?.handleReportPressed()
                }
            }) ~ self.disposeBag
    }
}

