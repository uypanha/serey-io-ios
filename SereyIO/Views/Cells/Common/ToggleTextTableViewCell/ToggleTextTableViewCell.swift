//
//  ToggleTextTableViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 12/19/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

class ToggleTextTableViewCell: BaseTableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var switchView: UISwitch!
    
    var cellModel: ToggleTextCellModel? {
        didSet {
            guard let viewModel = self.cellModel else {
                return
            }
            
            viewModel.image.bind(to: self.iconImageView.rx.image).disposed(by: self.disposeBag)
            viewModel.titleText.bind(to: self.titleLabel.rx.text).disposed(by: self.disposeBag)
            viewModel.toggleSwitcher.bind(to: self.switchView.rx.isOn).disposed(by: self.disposeBag)
            viewModel.indicatorAccessory
                .subscribe(onNext: { indicatorAccessory in
                    self.accessoryView = indicatorAccessory ? ViewUtiliesHelper.prepareIndicatorAccessory() : nil
                }).disposed(by: self.disposeBag)
            viewModel.showSeperatorLine.asObservable()
                .subscribe(onNext: { [weak self] showSeperatorLine in
                    self?.removeAllBorders()
                    if (showSeperatorLine) {
                        self?.addBorder(edges: .bottom, color: UIColor.lightGray.withAlphaComponent(0.5), thickness: 1)
                    }
                }).disposed(by: self.disposeBag)
            
            setUpRxObservers()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}


// MAKR: - SetUp Rx Observers
extension ToggleTextTableViewCell {
    
    func setUpRxObservers() {
        setUpSwitcherObservers()
    }
    
    func setUpSwitcherObservers() {
        self.switchView.rx.isOn.asObservable()
            .skip(1)
            .map { _ in ToggleTextCellModel.Action.toggleSwitch }
            .subscribe(onNext: { [weak self] action in
                self?.cellModel?.didAction(with: action)
            }).disposed(by: self.disposeBag)
    }
}
