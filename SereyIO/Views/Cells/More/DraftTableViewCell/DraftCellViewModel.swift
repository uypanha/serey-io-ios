//
//  DraftCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 12/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding

class DraftCellViewModel: CellViewModel {
    
    let draft: BehaviorRelay<DraftModel>
    let thumbnailURL: BehaviorSubject<URL?>
    let thumbnailImage: BehaviorSubject<UIImage?>
    let titleText: BehaviorSubject<String?>
    let descriptionText: BehaviorSubject<String?>
    
    let continuteEditDraft: PublishSubject<DraftModel>
    
    init(_ draft: DraftModel) {
        self.draft = .init(value: draft)
        self.thumbnailURL = .init(value: draft.imageURL)
        self.thumbnailImage = .init(value: draft.image)
        self.titleText = .init(value: draft.title)
        self.descriptionText = .init(value: draft.descriptionText)
        self.continuteEditDraft = .init()
        super.init()
    }
    
    func continueEditDraftPressed() {
        self.continuteEditDraft.onNext(self.draft.value)
    }
}
