//
//  FilteredCategoryTableViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/29/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import MaterialComponents

class FilteredCategoryTableViewCell: BaseTableViewCell {

    @IBOutlet weak var stackView: UIStackView!
    
    lazy var chipView: MDCChipView = MDCChipView()
    lazy var clearButton: CircularButton = {
        return CircularButton().then {
            $0.setImage(R.image.smallCloseIcon(), for: .normal)
            $0.customStyle(with: .darkGray)
            $0.tintColor = UIColor.white.withAlphaComponent(0.9)
            $0.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        }
    }()
    
    var cellModel: FilteredCategoryCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            cellModel.nameText ~> self.chipView.titleLabel.rx.text ~ self.disposeBag
            setUpClearButtonObservers(cellModel)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.stackView.addArrangedSubview(self.chipView)
        self.chipView.setShadowColor(.clear, for: .normal)
        self.chipView.setInkColor(.clear, for: .normal)
        self.chipView.setBackgroundColor(self.chipView.backgroundColor(for: .normal), for: .selected)
        self.chipView.accessoryView = self.clearButton
        self.chipView.accessoryPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.separatorInset = UIEdgeInsets(top: 0, left: self.frame.width, bottom: 0, right: 0)
    }
    
    private func prepareCircularButton(_ image: UIImage?) -> CircularButton {
        return CircularButton().then { // [unowned self] in
            $0.setImage(image, for: .normal)
            $0.customStyle(with: .darkGray)
            $0.tintColor = UIColor.white.withAlphaComponent(0.9)
            $0.imageEdgeInsets = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        }
    }
    
    private func setUpClearButtonObservers(_ cellModel: FilteredCategoryCellViewModel) {
        self.clearButton.rx.tap.asObservable()
            .map { FilteredCategoryCellViewModel.Action.removeFilterPressed }
            ~> cellModel.didActionSubject
            ~ self.disposeBag
    }
}
