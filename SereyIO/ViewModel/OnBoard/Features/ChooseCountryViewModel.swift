//
//  ChooseCountryViewModel.swift
//  SereyIO
//
//  Created by Panha Uy on 7/9/21.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import CountryPicker

class ChooseCountryViewModel: FeatureViewModel, ShouldReactToAction, ShouldPresent {
    
    enum Action {
        case countryPickerPressed
        case detectCountryPressed
        case countrySelected(CountryModel)
    }
    
    enum ViewToPresent {
        case openCountryPicker
        case detectigCountry(Bool)
    }
    
    // input:
    let didActionSubject: PublishSubject<Action>
    
    // output:
    let shouldPresentSubject: PublishSubject<ViewToPresent>
    
    let selectedCountry: BehaviorRelay<CountryModel?>
    let userService: UserService
    
    override init(_ feature: FeatureBoarding) {
        self.didActionSubject = .init()
        self.shouldPresentSubject = .init()
        
        self.selectedCountry = .init(value: nil)
        self.userService = .init()
        super.init(feature)
        
        setUpRxObservers()
    }
}

// MARK: - Networks
extension ChooseCountryViewModel {
    
    func fetchIpTrace() {
        self.shouldPresent(.detectigCountry(true))
        self.userService.fetchIpTrace()
            .subscribe(onNext: { [weak self] data in
                self?.shouldPresent(.detectigCountry(false))
                if let loc = data?.split(separator: "\n").first(where: { $0.contains("loc=") }) {
                    let countryCode = loc.replacingOccurrences(of: "loc=", with: "")
                    if let country = CountryManager.shared.country(withCode: countryCode) {
                        self?.selectedCountry.accept(.init(countryName: country.countryName, iconUrl: nil))
                    }
                }
            }, onError: { [weak self] error in
                self?.shouldPresent(.detectigCountry(false))
                let errorInfo = ErrorHelper.prepareError(error: error)
                self?.shouldPresentError(errorInfo)
            }) ~ self.disposeBag
    }
}

// MARK: - Action Handlers
fileprivate extension ChooseCountryViewModel {
    
    func handleCountryPickerPressed() {
        self.shouldPresent(.openCountryPicker)
    }
}

// MARK: - SetUp RxObservers
extension ChooseCountryViewModel {
    
    func setUpRxObservers() {
        setUpActionObservers()
    }
    
    func setUpActionObservers() {
        self.didActionSubject.asObservable()
            .subscribe(onNext: { [weak self] action in
                switch action {
                case .detectCountryPressed:
                    self?.fetchIpTrace()
                case .countryPickerPressed:
                    self?.handleCountryPickerPressed()
                case .countrySelected(let country):
                    PreferenceStore.shared.currentUserCountry = country.countryName
                    PreferenceStore.shared.currentUserCountryIconUrl = country.iconUrl
                    self?.selectedCountry.accept(country)
                }
            }) ~ self.disposeBag
    }
}
