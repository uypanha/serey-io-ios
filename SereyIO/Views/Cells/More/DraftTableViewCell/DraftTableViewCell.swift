//
//  DraftTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 12/24/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class DraftTableViewCell: BaseTableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var cellModel: DraftCellViewModel? {
        didSet {
            self.thumbnailImageView.image = nil
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.thumbnailURL.filter { $0 != nil }.map { $0 }.bind(to: self.thumbnailImageView.kf.rx.image()),
                cellModel.thumbnailImage.filter { $0 != nil } ~> self.thumbnailImageView.rx.image,
                cellModel.titleText ~> self.titleLabel.rx.text,
                cellModel.descriptionText ~> self.descriptionLabel.rx.text
            ]
            
            setUpRxObservers()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.selectionStyle = .none
        self.thumbnailImageView.contentMode = .scaleAspectFill
        self.thumbnailImageView.setRadius(all: 8)
        self.thumbnailImageView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        self.continueButton.primaryStyle()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.continueButton.makeMeCircular()
    }
}

// MARK: - SetUp RxObservers
extension DraftTableViewCell {
    
    func setUpRxObservers() {
        setUpControlObservers()
    }
    
    func setUpControlObservers() {
        self.continueButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.cellModel?.continueEditDraftPressed()
            }) ~ self.disposeBag
    }
}
