//
//  ProfileTableViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/11/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class ProfileTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var seeProfileLabel: UILabel!
    
    var cellModel: ProfileCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.profileViewModel ~> self.profileView.rx.profileViewModel,
                cellModel.authorName ~> self.profileNameLabel.rx.text,
                cellModel.showSeperatorLine.asObservable()
                    .subscribe(onNext: { [weak self] showSeperatorLine in
                        self?.removeAllBorders()
                        if (showSeperatorLine) {
                            self?.addBorder(edges: .bottom, color: UIColor.lightGray.withAlphaComponent(0.5), thickness: 1)
                        }
                    })
            ]
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.accessoryView = ViewUtiliesHelper.prepareIndicatorAccessory()
    }
}
