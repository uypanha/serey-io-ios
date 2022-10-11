//
//  SereyDrum.swift
//  SereyIO
//
//  Created by Panha Uy on 14/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

class SereyDrum {
    
    var rootViewController: DrumRootViewController
    
    static var shared: SereyDrum? = {
        return SereyDrum()
    }()
    
    init() {
        self.rootViewController = DrumRootViewController()
    }
    
    static func newInstance() -> SereyDrum {
        self.shared = SereyDrum()
        return self.shared!
    }
}
