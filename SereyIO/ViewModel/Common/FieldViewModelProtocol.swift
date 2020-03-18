//
//  FieldViewModelProtocol.swift
//  SereyIO
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

// FieldViewModel
protocol FieldViewModelProtocol {
    
    var errorMessage: String? { get }
    var textValidation: TextFieldValidation { get set }
    
    // Observables
    var titleText: BehaviorSubject<String?> { get set }
    var textFieldText: BehaviorRelay<String?> { get set }
    var errorText: BehaviorRelay<String?> { get}
    var textFieldPlaceholder: BehaviorSubject<String?> { get set }
    
    init(withTextFieldModel textFieldModel: TextFieldModel)
    
    // Validation
    func validate() -> Bool
}

extension FieldViewModelProtocol {
    
    func validateSize(_ value: String, size: (min:Int, max:Int)) -> Bool {
        return (size.min...size.max).contains(value.count)
    }
    
}

// MARK: TextField Validation Type
enum TextFieldValidation {
    case email
    case min(Int)
    case notEmpty
    case password(Int)
    case phone
    case none
    
    func validate(textToValidate text: String) -> Bool {
        switch self {
        case .email:
            return Constants.PatternValidation.email.validate(text)
        case .notEmpty:
            return !text.isEmpty
        case .min(let min):
            return text.count >= min
        case .phone:
            return Constants.PatternValidation.phone.validate(text)
        case .password(let min):
            return text.count >= min
        case .none:
            return true
        }
    }
}

// MARK: - TextFieldViewModel
class TextFieldViewModel: CellViewModel, FieldViewModelProtocol {
    
    var errorMessage: String?
    var textValidation = TextFieldValidation.notEmpty
    
    lazy var titleText = BehaviorSubject<String?>(value: nil)
    lazy var textFieldText = BehaviorRelay<String?>(value: nil)
    lazy var textFieldPlaceholder = BehaviorSubject<String?>(value: nil)
    lazy var errorText = BehaviorRelay<String?>(value: nil)
    lazy var shouldBecomeFirstResponder = PublishSubject<Bool>()
    
    var value: String? {
        get {
            return self.textFieldText.value
        }
        set(value) {
            self.textFieldText.accept(value)
        }
    }
    
    required init(withTextFieldModel textFieldModel: TextFieldModel) {
        super.init()
        
        self.errorMessage = textFieldModel.errorText
        self.textValidation = textFieldModel.textValidation
        
        self.titleText.onNext(textFieldModel.titleText)
        self.textFieldPlaceholder.onNext(textFieldModel.placeholderText)
        
        textFieldModel.textFieldText.asObservable()
            .filter({ [unowned self] in $0 != self.textFieldText.value })
            .subscribe(onNext: { [unowned self] text in
                self.textFieldText.accept(text ?? "")
            }).disposed(by: self.disposeBag)
        
        self.textFieldText.asObservable()
            .bind(to: textFieldModel.textFieldText)
            .disposed(by: self.disposeBag)
    }
    
    func validate() -> Bool {
        guard self.textValidation.validate(textToValidate: self.textFieldText.value ?? "") else {
            errorText.accept(errorMessage)
            return false
        }
        errorText.accept(nil)
        return true
    }
}

// Marks: - TextFieldViewModel Common TextField
extension TextFieldViewModel {
    
    static func userNameTextFieldViewModel() -> TextFieldViewModel {
        return textFieldWith(title: R.string.auth.userName.localized(), errorMessage: R.string.auth.userNameRequiredMessage.localized(), validation: .notEmpty)
    }
    
    static func privateKeyOrPwdTextFieldViewModel(_ placeholder: String = R.string.auth.privateKeyOrPassword.localized(), _ errorMessage: String = R.string.auth.privateKeyOrPasswordRequireMessage.localized()) -> TextFieldViewModel {
        return textFieldWith(title: placeholder, errorMessage: errorMessage, validation: .notEmpty)
    }
    
    static func textFieldWith(title: String, errorMessage: String? = nil, validation: TextFieldValidation = .none) -> TextFieldViewModel {
        let textFieldModel = TextFieldModel(titleText: title, placeholderText: title, textFieldText: BehaviorRelay(value: ""), errorText: errorMessage, textValidation: validation)
        
        return TextFieldViewModel(withTextFieldModel: textFieldModel)
    }
}

// Marks: - TextFieldViewModel Common TextField
extension TextFieldViewModel {
    
    func bind(with uitextView: UITextView) {
        (uitextView.rx.value <-> textFieldText).disposed(by: self.disposeBag)
    }
    
    func bind(with uitextField: UITextField, clearErrorOnEdit: Bool = true) {
        (uitextField.rx.value <-> textFieldText).disposed(by: self.disposeBag)
        textFieldPlaceholder.bind(to: uitextField.rx.placeholder).disposed(by: self.disposeBag)
        
        if clearErrorOnEdit {
            uitextField.rx.controlEvent(.editingChanged)
                .subscribe(onNext: { [weak self] _ in
                    self?.errorText.accept(nil)
                }).disposed(by: self.disposeBag)
        }
    }
    
    func bind(with textField: MDCTextField, controller: MDCTextInputControllerBase? = nil) {
        bind(with: textField as UITextField)
        errorText.asObservable()
            .subscribe(onNext: { errorText in
                controller?.setErrorText(errorText, errorAccessibilityValue: errorText)
            }).disposed(by: self.disposeBag)
    }
}

struct TextFieldModel {
    
    var titleText: String?
    var placeholderText: String?
    var textFieldText: BehaviorRelay<String?>
    var errorText: String?
    var textValidation: TextFieldValidation = TextFieldValidation.notEmpty
    
    init(titleText: String? = nil, placeholderText: String? = nil, textFieldText: BehaviorRelay<String?> = BehaviorRelay(value: nil), errorText: String? = nil, textValidation: TextFieldValidation = TextFieldValidation.notEmpty) {
        self.titleText = titleText
        self.placeholderText = placeholderText
        self.textFieldText = textFieldText
        self.errorText = errorText
        self.textValidation = textValidation
    }
}
