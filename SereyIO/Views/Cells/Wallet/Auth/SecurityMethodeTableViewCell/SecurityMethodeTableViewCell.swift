//
//  SecurityMethodeTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 6/15/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class SecurityMethodeTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var cellModel: SecurityMethodCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.iconImage ~> self.iconImageView.rx.image,
                cellModel.titleText ~> self.titleTextLabel.rx.text,
                cellModel.descriptionText ~> self.descriptionLabel.rx.text
            ]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.cardView.borderColor = .color(.border)
        self.iconImageView.makeMeCircular()
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.cardView.backgroundColor = selected ? .color(.primary).withAlphaComponent(0.2) : .white
            })
        } else {
            self.cardView.backgroundColor = selected ? .color(.primary).withAlphaComponent(0.2) : .white
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.cardView.backgroundColor = highlighted ? .color(.primary).withAlphaComponent(0.2) : .white
            })
        } else {
            self.cardView.backgroundColor = highlighted ? .color(.primary).withAlphaComponent(0.2) : .white
        }
    }
}
