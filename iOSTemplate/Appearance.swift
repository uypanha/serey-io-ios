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
    }
}

// Marks: - Preparation
fileprivate extension Appearance {
    
    static func prepareTableView() {
        UITableViewCell.appearance().selectedBackgroundView = UIView().then {
            $0.backgroundColor = ColorName.primary.color.withAlphaComponent(0.15)
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
