//
//  DraftSavedTableViewCell.swift
//  BlooiOS
//
//  Created by Panha Uy on 12/23/20.
//  Copyright © 2020 Serey. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class DraftSavedTableViewCell: BaseTableViewCell {

    @IBOutlet weak var containerCardView: CardView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var draftCountLabel: UILabel!
    
    var cardBackgroundColor: UIColor? {
        return UIColor(hexString: "EDF1FB")
    }
    
    var cellModel: DraftSavedCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            cellModel.draftCount ~> self.draftCountLabel.rx.text ~ self.disposeBag
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.selectionStyle = .none
        self.titleLabel.text = "See your draft articles"
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            self.containerCardView.backgroundColor = highlighted ? self.cardBackgroundColor?.withAlphaComponent(0.5) : self.cardBackgroundColor
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.separatorInset = .init(top: 0, left: self.frame.width, bottom: 0, right: 0)
    }
}
