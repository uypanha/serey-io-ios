//
//  PostDrumViewController+LoadViews.swift
//  SereyIO
//
//  Created by Panha Uy on 1/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RichEditorView

extension PostDrumViewController {
    
    func prepareViews() -> UIView {
        let mainView = UIView()
        mainView.backgroundColor = .white
        
        self.scrollView = ViewHelper.prepareScrollView { contentView in
            contentView.addSubview(self.editor)
            self.editor.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.right.equalToSuperview()
                self.editorHeightContraint = make.height.equalTo(self.minContentHeight)
            }
            
            contentView.addSubview(self.collectionView)
            self.collectionView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.height.greaterThanOrEqualTo(112)
                make.top.equalTo(self.editor.snp.bottom)
                make.bottom.equalToSuperview().inset(16)
            }
        }
        
        mainView.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            self.bottomConstraint = make.bottom.greaterThanOrEqualToSuperview().constraint.layoutConstraints.first
        }
        
        return mainView
    }
    
    func setUpEditorView(_ editorView: RichEditorView) {
        editorView.isScrollEnabled = false
        editorView.delegate = self
        editorView.inputAccessoryView = toolbar
        editorView.editorMargin = 16
        
        self.toolbar.delegate = self
        self.toolbar.editor = editorView
        
        editorView.webView.scrollView.contentSize.height = editorView.frame.height
    }
}

// MARK: - RichEditorView Delegate
extension PostDrumViewController: RichEditorDelegate, RichEditorToolbarDelegate {
    
    func richEditorDidLoad(_ editor: RichEditorView) {
        editor.editorMargin = 16
        editor.customCssAndJS()
        editor.setFontSize(14)
        let html = editor.html
        editor.html = html
        self.isFirstInitial = true
    }
    
    func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
        UIView.setAnimationsEnabled(false)
        self.editorHeightContraint.constraint.update(offset: (CGFloat(height) >= self.minContentHeight) ? CGFloat(height) : self.minContentHeight).activate()
        
        if self.isFirstInitial {
            let frame = self.editor.frame
            let y = CGFloat(height) < self.minContentHeight ? CGFloat(height) : (frame.height - 100)
            let rectToScroll = CGRect(x: 0, y: y, width: frame.width, height: 200)
            self.scrollView.scrollRectToVisible(rectToScroll, animated: false)
        }
        UIView.setAnimationsEnabled(true)
    }
    
    func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool {
        return false
    }
    
    func richEditor(_ editor: RichEditorView, contentDidChange content: String) {
        self.viewModel.descriptionTextField.value = content
    }
    
    func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar) {
    }
}
