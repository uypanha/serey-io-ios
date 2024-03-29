//
//  MoreViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/2/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources
import CountryPicker

class MoreViewController: BaseViewController, AlertDialogController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var termsContainerView: UIView!
    @IBOutlet weak var privacyPolicyButton: UIButton!
    @IBOutlet weak var termServiceButton: UIButton!
    
    private lazy var logoBarItem: UIBarButtonItem = {
        let customView = UIImageView()
        customView.image = R.image.logo()
        return UIBarButtonItem(customView: customView)
    }()
    
    lazy var dataSource: RxTableViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    var viewModel: MoreViewModel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.removeNavigationBarBorder()
        self.viewModel.refreshScreen()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
        viewModel.downloadData()
    }
}

// MARK: - Preparations & Tools
extension MoreViewController {
    
    func setUpViews() {
        self.navigationItem.leftBarButtonItem = logoBarItem
        self.termsContainerView.addBorders(edges: [.top], color: UIColor.lightGray.withAlphaComponent(0.2))
        
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.delegate = self
        self.tableView.backgroundColor = .white
        self.tableView.separatorColor = self.tableView.backgroundColor
        self.tableView.sectionFooterHeight = CGFloat.leastNormalMagnitude
        
        self.tableView.tableFooterView = UIView()
        self.tableView.contentInset = .zero
        
        self.tableView.register(SignInTableViewCell.self)
        self.tableView.register(ProfileTableViewCell.self)
        self.tableView.register(ImageTextTableViewCell.self)
        self.tableView.register(ButtonTableViewCell.self)
    }
    
    func prepreDataSource() -> RxTableViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxTableViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, tableView, indexPath, item) -> UITableViewCell in
            switch item {
            case is SignInCellViewModel:
                let cell: SignInTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? SignInCellViewModel
                return cell
            case is ProfileCellViewModel:
                let cell: ProfileTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? ProfileCellViewModel
                return cell
            case is SettingCellViewModel:
                let cell: ImageTextTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? SettingCellViewModel
                return cell
            case is ButtonCellViewModel:
                let cell: ButtonTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? ButtonCellViewModel
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
    
    func showCountryPicker() {
//        let countryController = CountryPickerWithSectionViewController.presentController(on: self) { [weak self] (country: Country) in
//            guard let self = self else { return }
//
//            self.viewModel.didAction(with: .countrySelected(country))
//        }
//        countryController.flagStyle = .circular
//        countryController.isCountryDialHidden = true
//        countryController.labelFont = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
}

// MAKR: - TableView Delegate
extension MoreViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = self.viewModel.sectionTitle(in: section) else {
            return nil
        }
        let headerView = HeaderView()
        headerView.configureData(title, leftInset: 24)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let _ = self.viewModel.sectionTitle(in: section) else {
            return CGFloat.leastNormalMagnitude
        }
        return 60
    }
}

// MARK: - TabBarControllerDelegate
extension MoreViewController: TabBarControllerDelegate {
    
    func configureTabBar(_ tag: Int) {
        self.tabBarItem = UITabBarItem(title: R.string.more.more.localized(), image: R.image.tabMore(), selectedImage: R.image.tabMoreSelected())
        self.tabBarItem?.tag = tag
    }
}

// MARK: - SetUp RxObservers
fileprivate extension MoreViewController {
    
    func setUpRxObservers() {
        setUpControlsObservers()
        setUpTableViewObservers()
        setUpShouldPresentObservers()
        setUpShouldPresentErrorObsevers()
    }
    
    func setUpControlsObservers() {
        self.privacyPolicyButton.rx.tap.asObservable()
            .map { MoreViewModel.Action.privacyPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.termServiceButton.rx.tap.asObservable()
            .map { MoreViewModel.Action.termsPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpTableViewObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.itemSelected.asObservable()
            .`do`(onNext: {[weak self] in self?.tableView.deselectRow(at: $0, animated: true) })
            .map { MoreViewModel.Action.itemSelected($0) }
            .bind(to: self.viewModel.didActionSubject)
            .disposed(by: self.disposeBag)
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [unowned self] viewToPresent in
                switch viewToPresent {
                case .signInController:
                    if let signInViewController = R.storyboard.auth.signInViewController() {
                        signInViewController.viewModel = SignInViewModel()
                        self.show(CloseableNavigationController(rootViewController: signInViewController), sender: nil)
                    }
                case .accountViewController(let accountViewModel):
                    if let accountViewController = R.storyboard.profile.userAccountViewController() {
                        accountViewController.viewModel = accountViewModel
                        self.show(accountViewController, sender: nil)
                    }
                case .languagesViewController:
                    let languagesViewController = LanguagesViewController()
                    languagesViewController.viewModel = ChooseLanguageViewModel()
                    self.show(languagesViewController, sender: nil)
                case .webViewController(let webViewViewModel):
                    let webViewController = WebViewViewController()
                    webViewController.viewModel = webViewViewModel
                    if #available(iOS 13.0, *) {
                        webViewController.isModalInPresentation = true // available in IOS13
                    }
                    self.present(UINavigationController(rootViewController: webViewController), animated: true, completion: nil)
                case .moreAppsController(let moreAppsViewModel):
                    let listTableViewController = MoreAppsViewController(moreAppsViewModel)
                    listTableViewController.title = "Serey Apps"
                    self.show(listTableViewController, sender: nil)
                case .signOutDialog:
                    self.showDialog(nil, title: R.string.settings.signOutQ.localized(), message: R.string.settings.signOutMessage.localized(), dismissable: false, positiveButton: R.string.settings.signOut.localized(), positiveCompletion: {
                        self.viewModel.didAction(with: .signOutConfirmed)
                    }, negativeButton: R.string.common.no.localized())
                case .notificationSettingsController:
                    if let notificationSettingsViewController = R.storyboard.notifications.notificationSettingsViewController() {
                        notificationSettingsViewController.viewModel = NotificationSettingsViewModel()
                        self.show(notificationSettingsViewController, sender: nil)
                    }
                case .walletViewController:
                    let walletViewConroller = SereyWallet.newInstance().rootViewController
                    walletViewConroller.modalPresentationStyle = .fullScreen
                    self.present(walletViewConroller, animated: true, completion: nil)
                case .bottomListViewController(let bottomListMenuViewModel):
                    let bottomMenuViewController = BottomMenuViewController(bottomListMenuViewModel)
                    self.present(bottomMenuViewController, animated: true, completion: nil)
                case .myReferralIdViewConroller:
                    let myReferralIdViewController = MyReferralIdViewController()
                    self.show(myReferralIdViewController, sender: nil)
                case .sereyDrumController:
                    let sereyDrumController = SereyDrum.newInstance().rootViewController
                    sereyDrumController.modalPresentationStyle = .fullScreen
                    self.present(sereyDrumController, animated: true)
                }
            }).disposed(by: self.disposeBag)
    }
    
    func setUpShouldPresentErrorObsevers() {
//        self.viewModel.shouldPresentError.asObservable()
//            .subscribe(onNext: { [unowned self] errorInfo in
//                self.showDialogError(errorInfo, positiveButton: R.string.common.confirm.localized(), positiveCompletion: nil)
//            }).disposed(by: self.disposeBag)
    }
}
