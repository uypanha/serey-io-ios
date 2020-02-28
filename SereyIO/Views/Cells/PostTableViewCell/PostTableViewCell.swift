//
//  PostTableViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/4/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Kingfisher
import RxKingfisher

class PostTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var sereyValueContainerView: UIStackView!
    @IBOutlet weak var sereySymbolImageView: UIImageView!
    @IBOutlet weak var sereyValueLabel: UILabel!
    
    @IBOutlet weak var upVoteContainerView: UIStackView!
    @IBOutlet weak var upVoteImageView: UIImageView!
    @IBOutlet weak var upVoteCountLabel: UILabel!
    
    @IBOutlet weak var downVoteContainerView: UIStackView!
    @IBOutlet weak var downVoteImageView: UIImageView!
    @IBOutlet weak var downVoteCountLabel: UILabel!
    
    @IBOutlet weak var commentContainerView: UIStackView!
    @IBOutlet weak var commentImageView: UIImageView!
    @IBOutlet weak var commentCountLabel: UILabel!
    
    var cellModel: PostCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.authorName ~> self.authorNameLabel.rx.text,
                cellModel.publishedAt ~> self.publishDateLabel.rx.text,
                cellModel.tagText ~> self.tagLabel.rx.text,
                cellModel.titleText ~> self.titleLabel.rx.text,
                cellModel.sereyValue ~> self.sereyValueLabel.rx.text,
                cellModel.upVoteCount ~> self.upVoteCountLabel.rx.text,
                cellModel.downVoteCount ~> self.downVoteCountLabel.rx.text,
                cellModel.commentCount ~> self.commentCountLabel.rx.text,
                cellModel.thumbnailURL.asObservable().map { $0 }
                    .bind(to: self.thumbnailImageView.kf.rx.image(placeholder: ViewUtiliesHelper.prepareDefualtPlaceholder()))
            ]
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
