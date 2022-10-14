//
//  UserCommentReplyTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 4/25/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Shimmer

class UserCommentReplyTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var vwShimmer: FBShimmeringView!
    @IBOutlet weak var mainCardView: CardView!
    
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!
    
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var commentDescriptionLabel: UILabel!
    
    @IBOutlet weak var voteContainerView: UIStackView!
    @IBOutlet weak var sereyValueContainerView: UIStackView!
    @IBOutlet weak var sereySymbolImageView: UIImageView!
    @IBOutlet weak var sereyValueLabel: UILabel!
    
    @IBOutlet weak var upVoteImageView: UIImageView!
    @IBOutlet weak var upVoteCountLabel: UILabel!
    
    @IBOutlet weak var downVoteContainerView: UIStackView!
    @IBOutlet weak var downVoteImageView: UIImageView!
    @IBOutlet weak var downVoteCountLabel: UILabel!
    
    var cellModel: UserCommentReplyCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.profileViewModel ~> self.profileView.rx.profileViewModel,
                cellModel.authorName ~> self.authorNameLabel.rx.text,
                cellModel.publishedAt ~> self.publishDateLabel.rx.text,
                cellModel.titleText ~> self.postTitleLabel.rx.text,
                cellModel.contentAttributedString ~> self.commentDescriptionLabel.rx.attributedText,
                cellModel.sereyValue ~> self.sereyValueLabel.rx.text,
                cellModel.upVoteCount ~> self.upVoteCountLabel.rx.text,
                cellModel.downVoteCount ~> self.downVoteCountLabel.rx.text,
                cellModel.isDownvoteHidden ~> self.downVoteContainerView.rx.isHidden
            ]
            
            cellModel.isShimmering.asObservable()
                .subscribe(onNext: { [weak self] isShimmering in
                    self?.prepareShimmering(isShimmering)
                }) ~ self.disposeBag
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.vwShimmer.shimmeringSpeed = 400
        self.vwShimmer.contentView = self.mainView
        self.mainCardView.borderColor = .color(.border)
    }
}

// MARK: - Preparations & Tools
extension UserCommentReplyTableViewCell {
    
    private func prepareShimmering(_ isShimmering: Bool) {
        let backgroundColor = isShimmering ? .color(.shimmering).withAlphaComponent(0.5) : UIColor.clear
        let cornerRadius : CGFloat = isShimmering ? 8 : 0
        let isHidden = isShimmering
        
        self.profileView.backgroundColor = backgroundColor
        self.authorNameLabel.backgroundColor = backgroundColor
        self.authorNameLabel.setRadius(all: cornerRadius)
        self.publishDateLabel.backgroundColor = backgroundColor
        self.publishDateLabel.setRadius(all: cornerRadius)
        
        self.postTitleLabel.backgroundColor = backgroundColor
        self.postTitleLabel.setRadius(all: cornerRadius)
        
        self.commentDescriptionLabel.backgroundColor = backgroundColor
        self.commentDescriptionLabel.setRadius(all: cornerRadius)
        
        self.sereyValueContainerView.isHidden = isHidden
        self.voteContainerView.isHidden = isHidden
        self.commentImageView.isHidden = isHidden
        
        DispatchQueue.main.async {
            self.vwShimmer.isShimmering = isShimmering
        }
    }
}
