//
//  SelectLanguageViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 1/27/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class SelectLanguageViewController: BaseViewController {
    
    @IBOutlet weak var selectLanguageLabel: UILabel!
    @IBOutlet weak var englishButton: UICenteredHorizantalButton!
    @IBOutlet weak var khmerButton: UICenteredHorizantalButton!
    
    var viewModel: SelectLanguageViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension SelectLanguageViewController {
    
    func setUpViews() {
        self.englishButton.makeMeCircular()
        self.englishButton.setBorder(borderWith: 1, borderColor: ColorName.primary.color)
        
        self.khmerButton.makeMeCircular()
        self.khmerButton.setBorder(borderWith: 1, borderColor: ColorName.primary.color)
    }
}

// MARK: - SetUP Rx Observers
fileprivate extension SelectLanguageViewController {
    
    func setUpRxObservers() {
        setUpControlsObservers()
        setUpShouldPresentObservers()
    }
    
    func setUpControlsObservers() {
        self.englishButton.rx.tap
            .map { Languages.en }
            .map { SelectLanguageViewModel.Action.languageSelected($0) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.khmerButton.rx.tap
            .map { Languages.km }
            .map { SelectLanguageViewModel.Action.languageSelected($0) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .boardingViewController:
                    DispatchQueue.main.async {
                        AppDelegate.shared?.rootViewController?.switchToBoardingScreen()
                    }
                }
            }) ~ self.disposeBag
    }
}

