//
//  CreateCredentialTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 7/26/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class CreateCredentialTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var cellModel: CreateCredentialCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.cardView.borderColor = ColorName.border.color
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.cardView.backgroundColor = selected ? ColorName.primary.color.withAlphaComponent(0.2) : .white
            })
        } else {
            self.cardView.backgroundColor = selected ? ColorName.primary.color.withAlphaComponent(0.2) : .white
        }
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.cardView.backgroundColor = highlighted ? ColorName.primary.color.withAlphaComponent(0.2) : .white
            })
        } else {
            self.cardView.backgroundColor = highlighted ? ColorName.primary.color.withAlphaComponent(0.2) : .white
        }
    }
}
