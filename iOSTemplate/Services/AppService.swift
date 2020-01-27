//
//  AppService.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import Alamofire

/// An `Error` emitted by `AppService Provider`.
enum AppError: Error {
    case appApiError(AppApiError)
}

// Represents an error encountered during the execution of a AppService operation.
struct AppApiError: Error, Codable {
    
    var error: String
    var errorDescription: String?
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case error = "error"
        case errorDescription = "error_description"
        case message = "Message"
    }
}
