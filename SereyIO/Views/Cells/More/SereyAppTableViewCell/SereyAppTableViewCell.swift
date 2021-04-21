//
//  SereyAppTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 4/29/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

enum SereyApp: CaseIterable {
    case sereySquare
    case sereyWallet
    case sereyLottery
    case sereySour
    
    var imageTextModel: ImageTextModel {
        switch self {
        case .sereyWallet:
            return ImageTextModel(image: R.image.walletApp(), titleText: "Serey Wallet", subTitle: "Download it at serey.io")
        case .sereySquare:
            return ImageTextModel(image: R.image.marketplaceApp(), titleText: "Serey Marketplace")
        case .sereyLottery:
            return ImageTextModel(image: R.image.lotteryApp(), titleText: "Serey Lottery", subTitle: "Coming Soon")
        case .sereySour:
            return ImageTextModel(image: R.image.sourApp(), titleText: "Serey Sour", subTitle: "Coming Soon")
        }
    }
    
    var indicatorAccessory: Bool {
        switch self {
        case .sereySquare:
            return true
        default:
            return false
        }
    }
    
    var url: URL? {
        switch self {
        case .sereySquare:
            return URL(string: "https://square.serey.io")
        default:
            return nil
        }
    }
}

class SereyAppTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var logoImageVIew: UIImageView!
    @IBOutlet weak var appNameLabel: UILabel!
    @IBOutlet weak var comingSoonLabel: UILabel!
    
    var cellModel: SereyAppCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.image ~> self.logoImageVIew.rx.image,
                cellModel.titleText ~> self.appNameLabel.rx.text,
                cellModel.subTitle ~> self.comingSoonLabel.rx.text
            ]
            
            cellModel.subTitle
                .map { $0 == nil }
                .bind(to: self.comingSoonLabel.rx.isHidden)
                .disposed(by: self.disposeBag)
            
            cellModel.indicatorAccessory
                .map { $0 ? ViewUtiliesHelper.prepareIndicatorAccessory() : nil }
                .subscribe(onNext: { [weak self] indicatorView in
                    self?.accessoryView = indicatorView
                }).disposed(by: self.disposeBag)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.logoImageVIew.setRadius(all: 10)
    }
}
