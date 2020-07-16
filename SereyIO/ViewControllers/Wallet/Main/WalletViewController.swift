//
//  WalletViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/24/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources

class WalletViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewHeightConstraint: NSLayoutConstraint!
    
    lazy var settingButton = UIBarButtonItem(image: R.image.settingsIcon(), style: .plain, target: nil, action: nil)
    
    var viewModel: WalletViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.showNavigationBarBorder()
    }
    
    override func setUpLocalizedTexts() {
        super.setUpLocalizedTexts()
        
        self.title = R.string.wallet.myWallet.localized()
    }
}

// MARK: - Preparations & Tools
extension WalletViewController {
    
    func setUpViews() {
        prepareCollectionView()
        
        self.navigationItem.rightBarButtonItem = self.settingButton
        self.viewHeightConstraint.constant = -self.bottomSafeAreaHeight
    }
    
    func prepareCollectionView() {
        if let collectionViewLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            collectionViewLayout.scrollDirection = .horizontal
        }
        self.collectionView.delegate = self
        self.collectionView.register(WalletCardCollectionViewCell.self)
    }
}

// MARK: - UICollectionViewDelegate
extension WalletViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

// MARK: - SetUp RxObservers
extension WalletViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.collectionView.rx.items) { collectionView, index, item in
                switch item {
                case is WalletCardCellViewModel:
                    let cell: WalletCardCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: IndexPath(row: index, section: 0))
                    cell.cellModel = item as? WalletCardCellViewModel
                    return cell
                default:
                    return UICollectionViewCell()
                }
            } ~ self.disposeBag
    }
}
