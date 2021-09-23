//
//  WebViewViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import Foundation

class WebViewViewModel: BaseViewModel {
    
    var urlToLoad: URL?
    var stringToLoad: String?
    
    var shouldLoadString: Bool {
        return stringToLoad != nil
    }
    
    var shouldLoadUrl: Bool {
        return urlToLoad != nil
    }
    
    private var webViewTitle: String?
    var title: String {
        return webViewTitle ?? ""
    }
    
    init(withStringToLoad stringToLoad: String?, title: String? = R.string.common.webViewDefaultTitle.localized()) {
        self.webViewTitle = title
        self.stringToLoad = stringToLoad
    }
    
    init(withURLToLoad urlToLoad: URL?, title: String? = R.string.common.webViewDefaultTitle.localized()) {
        self.webViewTitle = title
        self.urlToLoad = urlToLoad
    }
}
