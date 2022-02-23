//
//  WalletViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/24/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class WalletViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var menuCollectionView: ContentSizedCollectionView!
    @IBOutlet weak var transactionButton: UIButton!
    
    lazy var settingButton = UIBarButtonItem(image: R.image.settingsIcon(), style: .plain, target: nil, action: nil)
    
    var menuColumn: CGFloat { return 2 }
    var menuSpace: CGFloat { return 16 }
    
    var viewModel: WalletViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
        viewModel.initialNetworkConnection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarColor(.color(.navigationBg), tintColor: .color(.navigationTint))
        self.navigationController?.showNavigationBarBorder()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.title = R.string.wallet.myWallet.localized()
        self.transactionButton.setTitle("See Transaction History", for: .normal)
    }
}

// MARK: - Preparations & Tools
extension WalletViewController {
    
    func setUpViews() {
        prepareWalletCollectionView()
        prepareMenuCollectionView()
        
        self.navigationItem.rightBarButtonItem = self.settingButton
        self.viewHeightConstraint.constant = -self.bottomSafeAreaHeight
        self.transactionButton.setRadius(all: 8)
        self.transactionButton.setTitleColor(.color(.primary), for: .normal)
        self.transactionButton.tintColor = .color(.primary)
        self.transactionButton.customStyle(with: UIColor(hexString: "EDF1FB"))
    }
    
    func prepareWalletCollectionView() {
        self.collectionView.register(WalletCardCollectionViewCell.self)
        if let collectionViewLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.scrollDirection = .horizontal
        }
        self.collectionView.delegate = self
    }
    
    func prepareMenuCollectionView() {
        self.menuCollectionView.register(WalletMenuCollectionViewCell.self)
        self.menuCollectionView.delegate = self
    }
    
    func getMenuItemSize() -> CGSize {
        let viewWidth = self.view.frame.width
        let itemWidth = (viewWidth - self.menuSpace - (18 * 2)) / self.menuColumn
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func getCardItemSize() -> CGSize {
        return CGSize(width: self.collectionView.frame.width - 44, height: self.collectionView.frame.height - 32)
    }
}

// MARK: - UICollectionViewDelegate
extension WalletViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == self.collectionView ? 8 : self.menuSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return collectionView == self.collectionView ? 8 : self.menuSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? WalletMenuCollectionViewCell)?.setHighlighted(true, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        (collectionView.cellForItem(at: indexPath) as? WalletMenuCollectionViewCell)?.setHighlighted(false, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.menuCollectionView {
            return getMenuItemSize()
        } else {
            return getCardItemSize()
        }
    }
}

// MARK: - SetUp RxObservers
extension WalletViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.walletCells.asObservable()
            .bind(to: self.collectionView.rx.items) { [unowned self] collectionView, index, item in
                switch item {
                case is WalletCardCellViewModel:
                    let cell: WalletCardCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: IndexPath(row: index, section: 0))
                    cell.updateSized(self.getCardItemSize())
                    cell.cellModel = item as? WalletCardCellViewModel
                    return cell
                default:
                    return UICollectionViewCell()
                }
            } ~ self.disposeBag
        
        self.viewModel.cells.asObservable()
            .bind(to: self.menuCollectionView.rx.items) { [unowned self] collectionView, index, item in
                switch item {
                case is WalletMenuCellViewModel:
                    let cell: WalletMenuCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: IndexPath(row: index, section: 0))
                    cell.updateSize(self.getMenuItemSize())
                    cell.cellModel = item as? WalletMenuCellViewModel
                    return cell
                default:
                    return UICollectionViewCell()
                }
            } ~ self.disposeBag
    }
    
    func setUpControlObservers() {
        self.transactionButton.rx.tap.asObservable()
            .map { WalletViewModel.Action.transactionPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.menuCollectionView.rx.itemSelected.asObservable()
            .map { WalletViewModel.Action.itemSelected($0) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
        
        self.settingButton.rx.tap.asObservable()
            .map { WalletViewModel.Action.settingsPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .transactionController(let transactionHistoryViewModel):
                    let transactionHistoryViewController = TransactionHistoryViewController()
                    transactionHistoryViewController.viewModel = transactionHistoryViewModel
                    self?.show(transactionHistoryViewController, sender: nil)
                case .transferCoinController(let transferCoinViewModel):
                    if let transferViewController = R.storyboard.transfer.transferViewController() {
                        transferViewController.viewModel = transferCoinViewModel
                        self?.show(transferViewController, sender: nil)
                    }
                case .receiveCoinController(let receiveCoinViewModel):
                    if let receiveCoinViewController = R.storyboard.qrPayment.receiveCoinViewController() {
                        receiveCoinViewController.modalPresentationStyle = .overCurrentContext
                        receiveCoinViewController.modalTransitionStyle = .crossDissolve
                        receiveCoinViewController.viewModel = receiveCoinViewModel
                        self?.present(receiveCoinViewController, animated: true, completion: nil)
                    }
                case .scanQRViewController(let payQRViewModel):
                    if let payQRViewController = R.storyboard.qrPayment.payQRViewController() {
                        payQRViewController.viewModel = payQRViewModel
                        payQRViewController.modalPresentationStyle = .fullScreen
                        payQRViewController.modalTransitionStyle = .crossDissolve
                        self?.present(payQRViewController, animated: true, completion: nil)
                    }
                case .settingsController:
                    let settingsViewController = WalletSettingsViewController()
                    settingsViewController.viewModel = WalletSettingsViewModel()
                    self?.show(settingsViewController, sender: nil)
                case .powerUpController(let powerUpViewModel):
                    if let powerUpViewController = R.storyboard.power.powerUpViewController() {
                        powerUpViewController.viewModel = powerUpViewModel
                        self?.show(powerUpViewController, sender: nil)
                    }
                case .powerDownController(let powerDownViewModel):
                    if let powerDownViewController = R.storyboard.power.powerDownViewController() {
                        powerDownViewController.viewModel = powerDownViewModel
                        self?.show(powerDownViewController, sender: nil)
                    }
                case .claimRewardController(let claimRewardViewModel):
                    if let claimRewardViewController = R.storyboard.reward.claimRewardViewController() {
                        claimRewardViewController.viewModel = claimRewardViewModel
                        let bottomSheet = BottomSheetViewController(contentViewController: claimRewardViewController)
                        self?.present(bottomSheet, animated: true, completion: nil)
                    }
                case .cancelPowerDownController(let cancelPowerDownViewModel):
                    if let cancelPowerDownViewController = R.storyboard.power.cancelPowerDownViewController() {
                        cancelPowerDownViewController.viewModel = cancelPowerDownViewModel
                        let bottomSheet = BottomSheetViewController(contentViewController: cancelPowerDownViewController)
                        self?.present(bottomSheet, animated: true, completion: nil)
                    }
                case .delegatePowerController(let delegatePowerViewModel):
                    let delegatePowerController = DelegatePowerViewController()
                    delegatePowerController.viewModel = delegatePowerViewModel
                    self?.show(delegatePowerController, sender: nil)
                }
            }) ~ self.disposeBag
    }
}
