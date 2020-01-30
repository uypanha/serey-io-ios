//
//  SelectLanguageViewController.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 1/27/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class SelectLanguageViewController: BaseViewController {
    
    @IBOutlet weak var selectLanguageLabel: UILabel!
    @IBOutlet weak var tableView: ContentSizedTableView!
    
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var bottomLeftView: UIView!
    @IBOutlet weak var continueButtonHeightConstraint: NSLayoutConstraint!
    
    var viewModel: SelectLanguageViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.continueButton.setTitle(R.string.common.continue.localized(), for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.continueButton.roundCorners(corners: [.topLeft], radius: 24)
        self.bottomLeftView.roundCorners(corners: [.topRight], radius: 24)
    }
}

// MARK: - Preparations & Tools
extension SelectLanguageViewController {
    
    func setUpViews() {
        self.continueButton.backgroundColor = ColorName.primary.color
        self.continueButtonHeightConstraint.constant = 56 + self.bottomSafeAreaHeight
        self.continueButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.bottomSafeAreaHeight, right: 0)
        
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.register(LanguageTableViewCell.self)
    }
}

// MARK: - SetUP Rx Observers
fileprivate extension SelectLanguageViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlsObservers()
        setUpShouldPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items){ tableView, index, item in
                switch item {
                case is LanguageCellViewModel:
                    let cell: LanguageTableViewCell = tableView.dequeueReusableCell(forIndexPath: IndexPath(row: index, section: 0))
                    cell.cellModel = item as? LanguageCellViewModel
                    return cell
                default:
                    return UITableViewCell()
                }
            } ~ self.disposeBag
    }
    
    func setUpControlsObservers() {
        self.tableView.rx.itemSelected
            .`do`(onNext: { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }).map { SelectLanguageViewModel.Action.itemSelected($0) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { viewToPresent in
                switch viewToPresent {
                case .boardingViewController:
                    DispatchQueue.main.async {
                        AppDelegate.shared?.rootViewController?.switchToBoardingScreen()
                    }
                case .languagesBottomSheetController:
                    break
                }
            }) ~ self.disposeBag
    }
}

