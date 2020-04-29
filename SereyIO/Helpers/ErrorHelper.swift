//
//  ErrorHelper.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
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
        case unknownError = 9000
        case unknownServerError = 9001
        case unauthenticatedError = 9002
        case userNotFound = 9004
        case networkOffline = 9999
        
        var errorTitle: String? {
            switch self {
            case .networkOffline:
                return R.string.common.networkOfflineTitle.localized()
            case .unknownServerError:
                return R.string.common.errorFetchingDataTitle.localized()
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
            case .unknownError:
                errorDescription = errorMessage ?? R.string.common.errorUnknownDescription.localized()
            case .unknownServerError:
                errorDescription = R.string.common.errorUknonwServerNotFoundDesc.localized()
            case .unauthenticatedError:
                errorDescription = errorMessage ?? R.string.common.notAuthenticated.localized()
            case .networkOffline:
                errorDescription = R.string.common.networkOfflineMessage.localized()
            case .userNotFound:
                errorDescription = "User not found."
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
        case .appApiError(let error):
            switch AppApiErrorCode(rawValue: error.0.statusCode ?? 0) {
            case .signinFailed?:
                return PredefinedError.unauthenticatedError.prepareError(errorMessage: error.0.message)
            case .unauthorized?, .accessDenied?, .unauthenticateError?:
                if AuthData.shared.isUserLoggedIn {
                    AuthData.shared.removeAuthData(notify: true)
                }
                return PredefinedError.unauthenticatedError.prepareError()
            case .userNotFound:
                return PredefinedError.userNotFound.prepareError()
            default:
                log.error(error)
                return defaultError(message: error.0.message)
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
}

fileprivate enum AppApiErrorCode: Int {
    case signinFailed = 0
    case unauthorized = 3
    case unauthenticateError = 4
    case accessDenied = 10
    case userNotFound = 12
}
