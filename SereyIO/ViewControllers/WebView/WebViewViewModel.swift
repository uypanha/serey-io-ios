//
//  WebViewViewModel.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
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
        return webViewTitle ?? R.string.common.webViewDefaultTitle.localized()
    }
    
    init(withStringToLoad stringToLoad: String?, title: String?) {
        self.webViewTitle = title
        self.stringToLoad = stringToLoad
    }
    
    init(withURLToLoad urlToLoad: URL?, title: String?) {
        self.webViewTitle = title
        self.urlToLoad = urlToLoad
    }
}
