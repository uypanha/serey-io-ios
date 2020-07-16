//
//  ShimmeringProtocol.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/28/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol ShimmeringProtocol {
    
    var isShimmering: BehaviorRelay<Bool> { get }
    
    init(_ isShimmering: Bool)
}
