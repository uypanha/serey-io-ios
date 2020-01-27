//
//  CollectionDataProviderModel.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 1/11/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol CollectionDataProviderModel {
    associatedtype T
    
    func numberOfSections() -> Int
    
    func numberOfItems(in section: Int) -> Int
    
    func item(at indexPath: IndexPath) -> T?
    
    func isLastItem(indexPath: IndexPath) -> Bool
    
    func isEmpty() -> Bool
}
