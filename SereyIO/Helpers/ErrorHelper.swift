//
//  ErrorHelper.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import Moya

public struct ErrorInfo {
    
    var error: Error
    var errorTitle: String?
    var errorIcon: UIImage?
    var prefinedErrorType: ErrorHelper.PredefinedError
    
    init(error: Error, type: ErrorHelper.PredefinedError, errorTitle: String? = R.string.common.error.localized(), errorIcon: UIImage? = R.image.errorSad()) {
        self.error = error
        self.prefinedErrorType = type
        self.errorTitle = errorTitle
        self.errorIcon = errorIcon
    }
}

class ErrorHelper {
    typealias Prefined = [Int : String?]
    
    fileprivate static var errorDomain = Constants.appBundleIndentifire
    
    enum PredefinedError: Int {
        case voteOnYourOwnPost = 0001
        case unknownError = 9000
        case unknownServerError = 9001
        case unauthenticatedError = 9002
        case invalidCredentials = 9004
        case commentIn20s = 9008
        case referralIdError = 9010
        case networkOffline = 9999
        
        var errorTitle: String? {
            switch self {
            case .voteOnYourOwnPost:
                return "Up Vote"
            case .networkOffline:
                return R.string.common.networkOfflineTitle.localized()
            case .unknownServerError:
                return R.string.common.errorFetchingDataTitle.localized()
            case .invalidCredentials:
                return R.string.auth.signIn.localized()
            default:
                return R.string.common.oops.localized()
            }
        }
        
        var errorIcon: UIImage? {
            switch self {
            case .unknownServerError:
                return R.image.errorWarning()
            default:
                return R.image.errorSad()
            }
        }
        
        func prepareError(errorMessage: String? = nil) -> ErrorInfo {
            let errorDescription: String
            
            switch self {
            case .voteOnYourOwnPost:
                errorDescription = "You can't up vote your own post!"
            case .unknownError:
                errorDescription = errorMessage ?? R.string.common.errorUnknownDescription.localized()
            case .unknownServerError:
                errorDescription = R.string.common.errorUknonwServerNotFoundDesc.localized()
            case .unauthenticatedError:
                errorDescription = errorMessage ?? R.string.common.notAuthenticated.localized()
            case .networkOffline:
                errorDescription = R.string.common.networkOfflineMessage.localized()
            case .commentIn20s:
                errorDescription = "You may only comment once every 20 seconds."
            case .invalidCredentials:
                errorDescription = errorMessage ?? "Your login credentials are incorrect. Please make sure you put in the right credentials"
            case .referralIdError:
                errorDescription = "To create referral link you have to login with a password"
            }
            
            return ErrorInfo(error: NSError(domain: ErrorHelper.errorDomain, code: self.rawValue, userInfo: [NSLocalizedDescriptionKey: errorDescription]), type: self, errorTitle: self.errorTitle, errorIcon: self.errorIcon)
        }
    }
    
    fileprivate static func prepareURLError(_ error: URLError) -> ErrorInfo {
        switch error.code {
        case .notConnectedToInternet:
            return PredefinedError.networkOffline.prepareError()
        case .cannotFindHost,
             .badURL,
             .timedOut,
             .unsupportedURL,
             .cannotFindHost,
             .cannotConnectToHost,
             .dnsLookupFailed,
             .badServerResponse:
            return PredefinedError.unknownServerError.prepareError()
        default:
            return defaultError()
        }
    }
    
    fileprivate static func prepareMoyaError(_ error: MoyaError) -> ErrorInfo {
        switch error {
        case .underlying(let error, _):
            if let urlError = error as? URLError {
                return self.prepareURLError(urlError)
            }
        default:
            log.error(error)
            return defaultError()
        }
        
        log.error(error)
        return defaultError()
    }
    
    fileprivate static func prepareAppError(_ error: AppError) -> ErrorInfo {
        switch error {
        case .appApiError(let error, _):
            switch AppApiErrorCode(rawValue: error.errorCode) {
            case .signinFailed?:
                return PredefinedError.unauthenticatedError.prepareError(errorMessage: error.message)
            case .unauthorized?, .accessDenied?, .unauthenticateError?:
                if AuthData.shared.isUserLoggedIn {
                    AuthData.shared.removeAuthData(notify: true)
                }
                return PredefinedError.unauthenticatedError.prepareError()
            case .userNotFound, .invalidCredentials:
                return PredefinedError.invalidCredentials.prepareError(errorMessage: error.message)
            case .commentIn20s:
                return PredefinedError.commentIn20s.prepareError()
            case .referralId:
                return PredefinedError.referralIdError.prepareError()
            default:
                log.error(error)
                return defaultError(message: error.message)
            }
        }
    }
    
    static func prepareError(error: Error) -> ErrorInfo {
        
        if let appError = error as? AppError {
            return self.prepareAppError(appError)
        }
        
        if let urlError = error as? URLError {
            return self.prepareURLError(urlError)
        }
        
        if let moyaError = error as? MoyaError {
            return self.prepareMoyaError(moyaError)
        }
        
        if (error as NSError).code == 401 {
            if AuthData.shared.isUserLoggedIn {
                AuthData.shared.removeAuthData(notify: true)
            }
            return PredefinedError.unauthenticatedError.prepareError()
        }
        
        log.error(error)
        return defaultError()
    }
    
    static func defaultError(message: String? = nil) -> ErrorInfo {
        return PredefinedError.unknownError.prepareError(errorMessage: message)
    }
    
    static func preparePredefineError(_ error: PredefinedError) -> ErrorInfo {
        return error.prepareError()
    }
}

fileprivate enum AppApiErrorCode: Int {
    case signinFailed = 0
    case unauthorized = 3
    case unauthenticateError = 4
    case accessDenied = 10
    case userNotFound = 12
    case invalidCredentials = 15
    case commentIn20s = 27
    case referralId = 131
}
