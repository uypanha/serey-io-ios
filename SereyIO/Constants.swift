//
//  Constants.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

public struct Constants {
    
    static var apiEndPoint: URL {
        return URL(string: ConfigSetting.urlProcol.value() + ConfigSetting.apiURL.value())!
    }
    
    static var kycURL: URL {
        return URL(string: ConfigSetting.urlProcol.value() + ConfigSetting.kycURL.value())!
    }
    
    static var chainURL: URL {
        return URL(string: ConfigSetting.urlProcol.value() + ConfigSetting.chainURL.value())!
    }
    
    static let shouldClearOutBadgeCountWhenFiredUp: Bool = true
    
    static var appBundleIndentifire: String {
        return Bundle.main.bundleIdentifier ?? "io.uyphanha.app"
    }
    
    static var appVersionName: String {
        return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? ""
    }
    
    static var includeWallet: Bool {
        return (ConfigSetting.includeWallet.value() as NSString).boolValue
    }
    
    public static let limitPerPage: Int = 10
    
    static var uploadImageUrl: String {
        return "\(apiEndPoint.absoluteString)/api/v1/Image/UploadNoToken"
    }
    
    static func clearStoreData() {
    }

    enum UserDefaultsKeys: String {
        case appHasRunBefore = "appHasRunBefore"
        case userDisabledNotifs = "userDisabledNotifs"
    }
    
    enum PatternValidation: String {
        case non = ""
        case email = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        case phone = "[0-9]{7,12}"
        
        func validate(_ string: String) -> Bool {
            return string.validate(with: self.rawValue)
        }
    }
    
    static var termAndConditionsUrl: URL? {
        get {
            return URL(string: "\(ConfigSetting.urlProcol.value() + ConfigSetting.baseDomain.value())/term-service")
        }
    }
    
    static var privacyAndPolicyUrl: URL? {
        get {
            return URL(string: "\(ConfigSetting.urlProcol.value() + ConfigSetting.baseDomain.value())/privacy-policy")
        }
    }
}

fileprivate enum ConfigSetting {
    
    case baseDomain
    case apiURL
    case kycURL
    case chainURL
    case urlProcol
    case includeWallet
    
    private var key: String {
        switch self {
        case .baseDomain:
            return "BASE_DOMAIN"
        case .apiURL:
            return "API_URL"
        case .kycURL:
            return "KYC_URL"
        case .chainURL:
            return "CHAIN_URL"
        case .urlProcol:
            return "URL_PROTOCOL"
        case .includeWallet:
            return "INCLUDE_WALLET"
        }
    }
    
    private var infoDict: [String: Any]  {
        get {
            if let dict = Bundle.main.infoDictionary {
                return dict
            } else {
                fatalError("Plist file not found")
            }
        }
    }
    
    func value() -> String {
        return self.infoDict[self.key] as! String
    }
}
