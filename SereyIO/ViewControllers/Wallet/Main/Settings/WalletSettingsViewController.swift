//
//  WalletSettingsViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 8/12/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class WalletSettingsViewController: BaseTableViewController, LoadingIndicatorController {
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    lazy var fileMediaHelper: MediaPickerHelper = .init(withPresenting: self)
    
    var viewModel: WalletSettingsViewModel!
    
    override init(style: UITableView.Style = .grouped) {
        super.init(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.loadCells()
        self.navigationController?.setNavigationBarColor(.color(.navigationBg), tintColor: .color(.navigationTint))
        self.navigationController?.showNavigationBarBorder()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.title = "Settings"
    }
}

// MARK: - Preparations & Tools
extension WalletSettingsViewController {
    
    func setUpViews() {
        prepareTableViews()
    }
    
    func prepareTableViews() {
        self.tableView.backgroundColor = .white
        self.tableView.separatorColor = self.tableView.backgroundColor
        self.tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        
        self.tableView.tableFooterView = UIView()
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 16, right: 0)
        
        self.tableView.register(WalletProfileTableViewCell.self)
        self.tableView.register(ImageTextTableViewCell.self)
        self.tableView.register(ToggleTextTableViewCell.self)
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is WalletSettingCellViewModel:
                let cell: ImageTextTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? WalletSettingCellViewModel
                return cell
            case is WalletProfileCellViewModel:
                let cell: WalletProfileTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? WalletProfileCellViewModel
                return cell
            case is WalletSettingToggleCellViewModel:
                let cell: ToggleTextTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? WalletSettingToggleCellViewModel
                return cell
            default:
                return UITableViewCell()
            }
        })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].model.header
        }
        
        return dataSource
    }
}

// MAKR: - TableView Delegate
extension WalletSettingsViewController {
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = self.viewModel.sectionTitle(in: section) else {
            return nil
        }
        let headerView = HeaderView()
        headerView.configureData(title, leftInset: 24)
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let _ = self.viewModel.sectionTitle(in: section) else {
            return CGFloat.leastNormalMagnitude
        }
        return 40
    }
}

// MARK: - SetUp RxObservers
extension WalletSettingsViewController {
    
    func setUpRxObservers() {
        setUpTableViewObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpTableViewObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemSelected.asObservable()
            .`do`(onNext: {[weak self] in self?.tableView.deselectRow(at: $0, animated: true) })
            .map { WalletSettingsViewModel.Action.itemSelected($0) }
            .bind(to: self.viewModel.didActionSubject)
            .disposed(by: self.disposeBag)
        
        self.fileMediaHelper.selectedPhotoSubject.asObservable()
            .subscribe(onNext: { [weak self] pickerModel in
                self?.viewModel.didAction(with: .photoSelected(pickerModel.first!))
            }) ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .changePasswordController(let changePasswordViewModel):
                    if let changePasswordController = R.storyboard.password.changePasswordViewController() {
                        changePasswordController.viewModel = changePasswordViewModel
                        self?.show(changePasswordController, sender: nil)
                    }
                case .activateGoogleOTPContronner(let activateGoogleOTPViewModel):
                    if let activateGoogleOTPController = R.storyboard.googleOTP.activateGoogleOTP2ViewController() {
                        activateGoogleOTPController.viewModel = activateGoogleOTPViewModel
                        self?.show(CloseableNavigationController(rootViewController: activateGoogleOTPController), sender: nil)
                    }
                case .activeBiometryViewController(let activeBiometryViewModel):
                    if let activeBiometryViewController = R.storyboard.biometry.activeBiometryViewController() {
                        activeBiometryViewController.viewModel = activeBiometryViewModel
                        self?.show(CloseableNavigationController(rootViewController: activeBiometryViewController), sender: nil)
                    }
                case .choosePhotoController:
                    self?.fileMediaHelper.showImagePicker()
                case .bottomListViewController(let bottomMenuListViewModel):
                    let bottomMenuViewController = BottomMenuViewController(bottomMenuListViewModel)
                    self?.present(bottomMenuViewController, animated: true, completion: nil)
                case .profileGalleryController:
                    let profileGalleryViewController = ProfileGalleryViewController()
                    profileGalleryViewController.hidesBottomBarWhenPushed = true
                    profileGalleryViewController.viewModel = .init()
                    self?.show(profileGalleryViewController, sender: nil)
                case .loading(let loading):
                    loading ? self?.showLoading() : self?.dismissLoading()
                }
            }) ~ self.disposeBag
    }
}
