//
//  ChooseCountryViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 7/9/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import CountryPicker
import FlagKit

class ChooseCountryViewController: BaseViewController, PageItemControllerProtocol {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var countryButton: AccesoryButton!
    @IBOutlet weak var detectButton: LoadingButton!
    
    var index: Int = 0
    
    var viewModel: ChooseCountryViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ChooseCountryViewController {
    
    func setUpViews() {
        self.countryButton.secondaryStyle()
        self.detectButton.setTitleColor(ColorName.primary.color, for: .normal)
        self.detectButton.customStyle(with: .clear)
    }
    
    func showCountryPicker() {
//        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
//            guard let self = self else { return }
//
//            self.viewModel.didAction(with: .countrySelected(country))
//        }
//        countryController.flagStyle = .circular
//        countryController.isCountryDialHidden = true
//        countryController.labelFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
}

// MARK: - SetUp RxObservers
extension ChooseCountryViewController {
    
    func setUpRxObservers() {
        setUpControlObservers()
        setUpContentChangedObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpControlObservers() {
        self.detectButton.rx.tap.asObservable()
            .map { ChooseCountryViewModel.Action.detectCountryPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.countryButton.rx.tap.asObservable()
            .map { ChooseCountryViewModel.Action.countryPickerPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.image ~> self.iconImageView.rx.image ~ self.disposeBag
        self.viewModel.title ~> self.titleLabel.rx.text ~ self.disposeBag
        self.viewModel.message ~> self.messageLabel.rx.text ~ self.disposeBag
        
        self.viewModel.selectedCountry
            .subscribe(onNext: { [weak self] country in
                if let country = country {
//                    let flag = Flag(countryCode: country.countryCode)
//                    self?.countryButton.setTitle(country.countryName, for: .normal)
//                    self?.countryButton.setImage(flag?.image(style: .circle), for: .normal)
                } else {
                    self?.countryButton.setTitle("Global", for: .normal)
                    self?.countryButton.setImage(R.image.earhIcon(), for: .normal)
                }
                self?.countryButton.secondaryStyle()
            }) ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .detectigCountry(let loading):
                    self?.detectButton.isLoading = loading
                case .openCountryPicker:
                    self?.showCountryPicker()
                }
            }) ~ self.disposeBag
    }
}
