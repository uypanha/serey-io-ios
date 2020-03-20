//
//  ProfileTableViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/11/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
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
                cellModel.authorName ~> self.profileNameLabel.rx.text
            ]
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.accessoryView = ViewUtiliesHelper.prepareIndicatorAccessory()
    }
}
