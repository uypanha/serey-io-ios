//
//  WebViewViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import WebKit

class WebViewViewController: UIViewController {
    
    lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        return WKWebView(frame: .zero, configuration: configuration)
    }()
    var progressView = UIActivityIndicatorView(style: .gray)
    
    private var isFullScreen : Bool = false
    
    override var prefersStatusBarHidden: Bool {
        get {
            return isFullScreen
        }
    }
    
    var viewModel: WebViewViewModel! {
        didSet {
            title = viewModel.title
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        loadContent()
        registerVideoPlayback()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    fileprivate func registerVideoPlayback() {
        // For FullSCreen Exit
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoExitFullScreen(_:)), name: NSNotification.Name("UIWindowDidBecomeHiddenNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoEnterFullScreen(_:)), name: UIWindow.didBecomeHiddenNotification, object: nil)
    }
    
    @objc func videoExitFullScreen(_ sender: Any) {
        self.isFullScreen = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func videoEnterFullScreen(_ sender: Any) {
        self.isFullScreen = true
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UIWindowDidBecomeHiddenNotification"), object: nil)
    }
}

// MARK: - Preparation
extension WebViewViewController {
    fileprivate func configureView() {
        configureWebView()
        prepareNavigationBarButtons()
    }
    
    private func configureWebView() {
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        webView.navigationDelegate = self
        
        webView.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func prepareNavigationBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "clearIcon"), style: .plain, target: self, action: #selector(closeButtonPressed(_:)))
    }
    
    fileprivate func loadContent() {
        if viewModel.shouldLoadUrl {
            if let urlToLoad = viewModel.urlToLoad {
                let request = URLRequest(url: urlToLoad)
                webView.load(request)
                progressView.startAnimating()
            }
        } else if viewModel.shouldLoadString {
            if let stringToLoad = viewModel.stringToLoad {
                webView.loadHTMLString(stringToLoad, baseURL: nil)
                progressView.startAnimating()
            }
        }
    }
}

// MARK: - Actions
extension WebViewViewController {
    @objc func closeButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - WebViewDelegate
extension WebViewViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.title == nil || self.title?.isEmpty == true {
            self.title = webView.title
        }
        progressView.stopAnimating()
    }
}
