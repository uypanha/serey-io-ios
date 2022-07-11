//
//  Appearance.swift
//  SereyIO
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import Then
import RichEditorView
import SkeletonView

class Appearance {
    
    static func configure() {
        prepareTableView()
        prepareNavigationBar()
        prepareTabBar()
        prepareRichEditorAppearance()
        prepareCustomBackImage()
    }
}

// Marks: - Preparation
fileprivate extension Appearance {
    
    static func prepareTableView() {
        UITableViewCell.appearance().selectedBackgroundView = UIView().then {
            $0.backgroundColor = .color(.primary).withAlphaComponent(0.15)
        }
        UITableView.appearance().separatorColor = .color(.border)
    }
    
    static func prepareTabBar() {
        UITabBar.appearance().tintColor = .color(.primary)
        if #available(iOS 10.0, *) {
            UITabBar.appearance().unselectedItemTintColor = .darkGray
        }
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = .color(.tabBarBg)
            UITabBar.appearance().standardAppearance = tabBarAppearance
            
            if #available(iOS 15, *) {
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            }
        } else {
            UITabBar.appearance().backgroundColor = .color(.tabBarBg)
        }
    }
    
    static func prepareNavigationBar() {
        //NavigationBar
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = .color(.navigationBg)
        UINavigationBar.appearance().tintColor = .color(.navigationTint)
        
        UINavigationBar.appearance().backgroundColor = .color(.navigationBg)
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor.color(.navigationTint)
        ]
        
        // change big title
        if #available(iOS 13, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.setBackIndicatorImage(R.image.leftArrowIcon(), transitionMaskImage: R.image.leftArrowIcon())
            navBarAppearance.titleTextAttributes = [
                .foregroundColor: UIColor.color(.navigationTint),
                .font: UIFont.systemFont(ofSize: 17, weight: .medium)
            ]
            
            navBarAppearance.backgroundColor = .color(.navigationBg)
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        } else if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [
                .foregroundColor: UIColor.color(.navigationTint),
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
        }
    }
    
    static func prepareCustomBackImage() {
        var backButtonImage = R.image.leftArrowIcon()
        backButtonImage = backButtonImage?.stretchableImage(withLeftCapWidth: 15, topCapHeight: 30)
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(backButtonImage, for: .normal, barMetrics: .default)
    }
    
    static func prepareRichEditorAppearance() {
        RichEditorToolbar.appearance.tintColor = UIColor.gray
        RichEditorToolbar.appearance.selectedTintColor = UIColor.black
        RichEditorToolbar.appearance.selectedBackgroundImage = R.image.toolbarBgSelected()
        RichEditorToolbar.appearance.backgroundImage = R.image.transaprent()
    }
    
    static func prepareSkeletonView() {
        SkeletonAppearance.default.tintColor = .color(.shimmering)
        SkeletonAppearance.default.multilineCornerRadius = 6
        SkeletonAppearance.default.skeletonCornerRadius = 6
        SkeletonAppearance.default.multilineSpacing = 6
    }
}
