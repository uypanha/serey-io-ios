//
//  Appearance.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/9/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit
import Then

class Appearance {
    
    static func configure() {
        prepareTableView()
        prepareNavigationBar()
        prepareTabBar()
    }
}

// Marks: - Preparation
fileprivate extension Appearance {
    
    static func prepareTableView() {
        UITableViewCell.appearance().selectedBackgroundView = UIView().then {
            $0.backgroundColor = ColorName.primary.color.withAlphaComponent(0.15)
        }
    }
    
    static func prepareTabBar() {
        UITabBar.appearance().tintColor = ColorName.primary.color
        if #available(iOS 10.0, *) {
            UITabBar.appearance().unselectedItemTintColor = UIColor.darkGray
        }
        if #available(iOS 13.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = .white
            UITabBar.appearance().standardAppearance = tabBarAppearance
        } else {
            UITabBar.appearance().backgroundColor = .white
        }
    }
    
    static func prepareNavigationBar() {
        //NavigationBar
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = ColorName.navigationTint.color
        UINavigationBar.appearance().tintColor = ColorName.navigationTint.color
        
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: ColorName.navigationTint.color
        ]
        
        // change big title
        if #available(iOS 13, *) {
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [
                .foregroundColor: ColorName.navigationTint.color,
                .font: UIFont.systemFont(ofSize: 17, weight: .medium)
            ]
            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        } else if #available(iOS 11.0, *) {
            UINavigationBar.appearance().largeTitleTextAttributes = [
                .foregroundColor: ColorName.navigationTint.color,
                .font: UIFont.boldSystemFont(ofSize: 24)
            ]
        }
    }
}
