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
    
    let imageUrl: BehaviorRelay<URL?>
    let image: BehaviorRelay<UIImage?>
    let buttonImage: BehaviorSubject<UIImage?>
    let buttonBackgroundColor: BehaviorSubject<UIColor?>
    let border: BehaviorSubject<(UIColor, CGFloat)>
    
    let isShimmering: BehaviorRelay<Bool>
    
    required convenience init(_ isShimmering: Bool) {
        self.init(nil)
        
        self.isShimmering.accept(isShimmering)
    }
    
    convenience init(image: UIImage?) {
        self.init(nil)
        
        self.image.accept(image)
    }
    
    init(_ url: URL?) {
        self.didActionSubject = .init()
        
        self.imageUrl = .init(value: url)
        self.image = .init(value: nil)
        self.buttonImage = .init(value: R.image.removeIcon())
        self.buttonBackgroundColor = .init(value: UIColor(hexString: "#F35050").withAlphaComponent(0.58))
        self.border = .init(value: (.clear, 0))
        self.isShimmering = .init(value: false)
        
        super.init()
    }
    
    func handleActionButtonPressed() {
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
