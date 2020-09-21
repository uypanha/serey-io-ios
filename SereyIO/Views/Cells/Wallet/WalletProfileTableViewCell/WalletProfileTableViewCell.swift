//
//  ProfileTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 8/12/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class WalletProfileTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var cameraButton: UIButton!
    
    var cellModel: WalletProfileCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.profileModel ~> self.profileView.rx.profileViewModel
            ]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.selectionStyle = .none
        self.cameraButton.makeMeCircular()
    }
}
