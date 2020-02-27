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
    
    public static let limitPerPage: Int = 10
    
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
            return URL(string: "https://www.example.com/Privacy")
        }
    }
}

fileprivate enum ConfigSetting {
    
    case apiURL
    case chainURL
    case urlProcol
    
    private var key: String {
        switch self {
        case .apiURL:
            return "API_URL"
        case .chainURL:
            return "CHAIN_URL"
        case .urlProcol:
            return "URL_PROTOCOL"
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
