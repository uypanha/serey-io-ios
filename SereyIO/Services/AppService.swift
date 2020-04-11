//
//  AppService.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

/// An `Error` emitted by `AppService Provider`.
enum AppError: Error {
    case appApiError(AppApiError, code: Int)
}

// MARK: - Base AppService
class AppService<T: TargetType> {
    
    lazy var disposeBag = DisposeBag()
    
    open var timeOut: TimeInterval {
        return 30
    }
    
    lazy var provider: MoyaProvider<T> = {
        var plugins: [PluginType] = []
        if let token = AuthData.shared.userToken {
            let tokenAuth = token
            plugins.append(AccessTokenPlugin { tokenAuth })
        }
        #if DEBUG
        plugins.append(NetworkLoggerPlugin(verbose: true))
        #endif
        var manager = DefaultAlamofireManager.sharedManager(self.timeOut)
        
        return MoyaProvider<T>(manager: manager, plugins: plugins)
    }()
    
    init() {}
}

// Represents an error encountered during the execution of a AppService operation.
struct AppApiError: Error, Codable {
    
    var errorCode: Int
    var statusCode: Int?
    var message: String?
    
    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case statusCode = "status_code"
        case message = "Message"
    }
}

// MARK: - None Authorization Api Type
protocol ApiTargetType: TargetType {
    
    var parameters: [String: Any] { get }
    
}

extension ApiTargetType {
    
    public var baseURL: URL {
        return Constants.apiEndPoint
    }
    
    var sampleData: Data {
        return Data()
    }
}

// MARK: - Authorization Api Type
protocol AuthorizedApiTargetType: ApiTargetType, AccessTokenAuthorizable {}

extension AuthorizedApiTargetType {
    
    public var authorizationType: AuthorizationType {
        return .bearer
    }
}

class DefaultAlamofireManager: Alamofire.SessionManager {
    
    static func sharedManager(_ timeout: TimeInterval = 30, _ includeDefaultHeaders: Bool = true) -> DefaultAlamofireManager {
        let configuration = URLSessionConfiguration.default
        if includeDefaultHeaders {
            let defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
            configuration.httpAdditionalHeaders = defaultHeaders
        }
        configuration.timeoutIntervalForRequest = 30 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 30 // as seconds, you can set your resource timeout
        return DefaultAlamofireManager(configuration: configuration) //, serverTrustPolicyManager: CustomServerTrustPoliceManager())
    }
}

class CustomServerTrustPoliceManager : ServerTrustPolicyManager {
    override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
        return .disableEvaluation
    }

    public init() {
        super.init(policies: [:])
    }
}
