//
//  BottomMenuViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/3/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import MaterialComponents

class BottomMenuViewController: BottomSheetListViewController {
    
    init(_ viewModel: BottomListMenuViewModel) {
        let listViewController = MenuListTableViewController(viewModel, .grouped)
        listViewController.view.backgroundColor = .white
        listViewController.sepereatorStyle = .none
        listViewController.contentInset = .init(top: 0, left: 0, bottom: 16, right: 0)
        listViewController.view.roundCorners(corners: [.topLeft, .topRight], radius: 12)
        listViewController.tableView.sectionFooterHeight = 0
        super.init(contentViewController: listViewController)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MenuListTableViewController: ListTableViewController<BottomListMenuViewModel> {
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as? UITableViewHeaderFooterView
        headerView?.contentView.backgroundColor = .white
        headerView?.textLabel?.textColor = .black
        if let font = self.viewModel.headerFont {
            headerView?.textLabel?.font = font
        } else {
            headerView?.textLabel?.font = .customFont(with: 16, weight: .regular)
        }
        headerView?.textLabel?.text = self.viewModel.sectionTitle(in: section)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.viewModel.sectionTitle(in: section) == " " {
            return 16
        }
        return 54
    }
}
