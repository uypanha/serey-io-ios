//
//  DeeplinkParser.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class DeeplinkParser {
    static let shared = DeeplinkParser()
    private init() { }
    
    func parseDeepLink(_ url: URL) -> DeeplinkType? {
        return .browser(url: url)
    }
}
