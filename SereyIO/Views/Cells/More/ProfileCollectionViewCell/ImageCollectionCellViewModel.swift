//
//  ImageCollectionCellViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 4/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import RxCocoa
import RxSwift
import RxBinding
import UIKit

class ImageCollectionCellViewModel: CellViewModel, ShimmeringProtocol, ShouldReactToAction {
    
    enum Action {
        case actionButtonPressed
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    let pickerModel: BehaviorRelay<PickerFileModel?>
    let imageUrl: BehaviorRelay<URL?>
    let image: BehaviorRelay<UIImage?>
    let buttonImage: BehaviorSubject<UIImage?>
    let buttonBackgroundColor: BehaviorSubject<UIColor?>
    let border: BehaviorSubject<(UIColor, CGFloat)>
    
    let isShimmering: BehaviorRelay<Bool>
    let shouldReactToAction: PublishSubject<Void>
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
    
    convenience init(image: UIImage?) {
        self.init(nil)
        
        self.image.accept(image)
    }
    
    convenience init(pickerModel: PickerFileModel) {
        self.init(nil)
        
        self.pickerModel.accept(pickerModel)
        pickerModel.previewImage.bind(to: self.image).disposed(by: self.disposeBag)
    }
    
    init(_ url: URL?) {
        self.didActionSubject = .init()
        
        self.pickerModel = .init(value: nil)
        self.imageUrl = .init(value: url)
        self.image = .init(value: nil)
        self.buttonImage = .init(value: R.image.removeIcon())
        self.buttonBackgroundColor = .init(value: UIColor(hexString: "#F35050").withAlphaComponent(0.58))
        self.border = .init(value: (.color(.shimmering).withAlphaComponent(0.5), 1.5))
        self.isShimmering = .init(value: false)
        self.shouldReactToAction = .init()
        
        super.init()
        
        setUpRxObservers()
    }
    
    func handleActionButtonPressed() {
        self.shouldReactToAction.onNext(())
    }
}

// MARK: - SetUp RxObservers
extension ImageCollectionCellViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .actionButtonPressed:
                    self?.handleActionButtonPressed()
                }
            }) ~ self.disposeBag
    }
}
