//
//  LanguageManager.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit
import Rswift

class LanguageManger {
    
    /// Returns the singleton LanguageManger instance.
    static let shared: LanguageManger = LanguageManger()
    
    /// Returns the currnet language
    var currentLanguage: Languages {
        get {
            
            guard let currentLang = UserDefaults.standard.string(forKey: "selectedLanguage") else {
                return defaultLanguage
            }
            return Languages(rawValue: currentLang)!
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedLanguage")
        }
    }
    
    /// Returns the default language that the app will run first time
    var defaultLanguage: Languages {
        get {
            
            guard let defaultLanguage = UserDefaults.standard.string(forKey: "defaultLanguage") else {
                return Languages(rawValue: Locale.current.identifier) ?? Languages.en
            }
            return Languages(rawValue: defaultLanguage)!
        }
        set {
            
            // swizzle the awakeFromNib from nib and localize the text in the new awakeFromNib
            UIView.localize()
            
            let defaultLanguage = UserDefaults.standard.string(forKey: "defaultLanguage")
            guard defaultLanguage == nil else {
                return
            }
            
            UserDefaults.standard.set(newValue.rawValue, forKey: "defaultLanguage")
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedLanguage")
            setLanguage(language: newValue)
        }
    }
    
    
    /// Returns the diriction of the language
    var isRightToLeft: Bool {
        get {
            let lang = currentLanguage.rawValue
            return lang.contains("ar") || lang.contains("he") || lang.contains("ur") || lang.contains("fa")
        }
    }
    
    /// Returns the app locale for use it in dates and currency
    var appLocale: Locale {
        get {
            return Locale(identifier: currentLanguage.rawValue)
        }
    }
    
    /// Returns list of the supported languages
    var supportedLanguages: [Languages] {
        get {
            return self.availableLanguages()
        }
    }
    
    ///
    /// Set the current language for the app
    ///
    /// - parameter language: The language that you need from the app to run with
    ///
    func setLanguage(language: Languages) {
        
        // change the dircation of the views
        let semanticContentAttribute:UISemanticContentAttribute = isRightToLeft ? .forceRightToLeft : .forceLeftToRight
        UIView.appearance().semanticContentAttribute = semanticContentAttribute
        UINavigationBar.appearance().semanticContentAttribute = semanticContentAttribute
        UITextField.appearance().semanticContentAttribute = semanticContentAttribute
        UITextView.appearance().semanticContentAttribute = semanticContentAttribute
        
        // change app language
        UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // set current language
        currentLanguage = language
        NotificationDispatcher.sharedInstance.dispatch(.languageChanged)
    }
    
    /**
     List available languages
     - Returns: Array of available languages.
     */
    private func availableLanguages(_ excludeBase: Bool = true) -> [Languages] {
        var availableLanguages = Bundle.main.localizations
        // If excludeBase = true, don't include "Base" in available languages
        if let indexOfBase = availableLanguages.firstIndex(of: "Base") , excludeBase == true {
            availableLanguages.remove(at: indexOfBase)
        }
        
        var languages: [Languages] = []
        availableLanguages.forEach { lang in
            if let language = Languages(rawValue: lang) {
                languages.append(language)
            }
        }
        
        return languages
    }
}

enum Languages: String, CaseIterable {
    //    case ar,en,nl,ja,ko,vi,ru,sv,fr,es,pt,it,de,da,fi,nb,tr,el,id,ms,th,hi,hu,pl,cs,sk,uk,hr,ca,ro,he
    //    case enGB = "en-GB"
    //    case enAU = "en-AU"
    //    case enCA = "en-CA"
    //    case enIN = "en-IN"
    //    case frCA = "fr-CA"
    //    case esMX = "es-MX"
    //    case ptBR = "pt-BR"
    //    case zhHans = "zh-Hans"
    //    case zhHant = "zh-Hant"
    //    case zhHK = "zh-HK"
    case en
    case km = "km-KH"
    
//    var image: UIImage? {
//        switch self {
//        case .en:
//            return R.image.englishIcon()
//        default:
//            return R.image.khmerIcon()
//        }
//    }
    
    var image: UIImage? {
        switch self {
        case .en:
            return R.image.enUs()
        default:
            return R.image.khKm()
        }
    }
    
    var languageText: String? {
        switch self {
        case .en:
            return "English"
        case .km:
            return "ខេមរៈភាសា"
        }
    }
    
    var languageCode: String {
        switch self {
        case .en:
            return "en"
        case .km:
            return "km"
        }
    }
    
    var isSelected: Bool {
        return self == LanguageManger.shared.currentLanguage
    }
    
    var languageModel: LanguageModel {
        return LanguageModel(lanuage: self)
    }
}


// MARK: Swizzling
extension UIView {
    
    static func localize() {
        
        let orginalSelector = #selector(awakeFromNib)
        let swizzledSelector = #selector(swizzledAwakeFromNib)
        
        let orginalMethod = class_getInstanceMethod(self, orginalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        
        let didAddMethod = class_addMethod(self, orginalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
        
        if didAddMethod {
            class_replaceMethod(self, swizzledSelector, method_getImplementation(orginalMethod!), method_getTypeEncoding(orginalMethod!))
        } else {
            method_exchangeImplementations(orginalMethod!, swizzledMethod!)
        }
        
    }
    
    @objc func swizzledAwakeFromNib() {
        swizzledAwakeFromNib()
        
        switch self {
        case let txtf as UITextField:
            txtf.text = txtf.text?.localize()
        case let lbl as UILabel:
            lbl.text = lbl.text?.localize()
        case let btn as UIButton:
            btn.setTitle(btn.title(for: .normal)?.localize(), for: .normal)
        default:
            break
        }
    }
}


// MARK: String extension
extension String {
    
    ///
    /// Localize the current string to the selected language
    ///
    /// - returns: The localized string
    ///
    func localize() -> String {
        guard let bundle = Bundle.main.path(forResource: LanguageManger.shared.currentLanguage.rawValue, ofType: "lproj") else {
            return NSLocalizedString(self, comment: "")
        }
        
        let langBundle = Bundle(path: bundle)
        return NSLocalizedString(self, tableName: nil, bundle: langBundle!, comment: "")
    }
    
}

// MARK: - StringResource extention
extension StringResource {
    
    ///
    /// Localize the current string to the selected language
    ///
    /// - returns: The localized string
    ///
    public func localized() -> String {
        guard
            let basePath = bundle.path(forResource: "Base", ofType: "lproj"),
            let baseBundle = Bundle(path: basePath)
            else {
                return self.key
        }
        
        let fallback = baseBundle.localizedString(forKey: key, value: key, table: tableName)
        
        guard
            let localizedPath = bundle.path(forResource: LanguageManger.shared.currentLanguage.rawValue, ofType: "lproj"),
            let localizedBundle = Bundle(path: localizedPath)
            else {
                return fallback
        }
        
        return localizedBundle.localizedString(forKey: key, value: fallback, table: tableName)
    }
}

// MARK: UIApplication extension
extension UIApplication {
    
    // Get top view controller
    static var topViewController: UIViewController? {
        get{
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                return topController
            }else{
                return nil
            }
        }
    }
    
}
