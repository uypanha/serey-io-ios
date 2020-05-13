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
import Shimmer

class PostTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var vwShimmer: FBShimmeringView!
    
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var tagContainerView: CircularView!
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
    
    private var categoryGesture: UITapGestureRecognizer? {
        didSet {
            guard let gesture = self.categoryGesture else { return }
            
            self.tagContainerView.isUserInteractionEnabled = true
            self.tagContainerView.addGestureRecognizer(gesture)
        }
    }
    
    private var profileViewGesture: UITapGestureRecognizer? {
        didSet {
            guard let gesture = self.profileViewGesture else { return }
            
            self.profileView.isUserInteractionEnabled = true
            self.profileView.addGestureRecognizer(gesture)
        }
    }
    
    private var profileLabelGesture: UITapGestureRecognizer? {
        didSet {
            guard let gesture = self.profileLabelGesture else { return }
            
            self.authorNameLabel.isUserInteractionEnabled = true
            self.authorNameLabel.addGestureRecognizer(gesture)
        }
    }
    
    var cellModel: PostCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.profileViewModel ~> self.profileView.rx.profileViewModel,
                cellModel.authorName ~> self.authorNameLabel.rx.text,
                cellModel.publishedAt ~> self.publishDateLabel.rx.text,
                cellModel.tags.map { $0.first?.capitalized } ~> self.tagLabel.rx.text,
                cellModel.titleText ~> self.titleLabel.rx.text,
                cellModel.sereyValue ~> self.sereyValueLabel.rx.text,
                cellModel.upVoteCount ~> self.upVoteCountLabel.rx.text,
                cellModel.downVoteCount ~> self.downVoteCountLabel.rx.text,
                cellModel.commentCount ~> self.commentCountLabel.rx.text,
                cellModel.thumbnailURL.asObservable().map { $0 }
                    .bind(to: self.thumbnailImageView.kf.rx.image(placeholder: ViewUtiliesHelper.prepareDefualtPlaceholder())),
                cellModel.isMoreHidden ~> self.moreButton.rx.isHidden
            ]
            
            cellModel.isShimmering.asObservable()
                .subscribe(onNext: { [weak self] isShimmering in
                    self?.prepareShimmering(isShimmering)
                }) ~ self.disposeBag
            
            setUpControlsObservers()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.vwShimmer.shimmeringSpeed = 400
        self.vwShimmer.contentView = self.mainView
        self.categoryGesture = UITapGestureRecognizer()
        self.profileViewGesture = UITapGestureRecognizer()
    }
}

// MARK: - Preparations & Tools
extension PostTableViewCell {
    
    private func prepareShimmering(_ isShimmering: Bool) {
        let backgroundColor = isShimmering ? ColorName.shimmering.color.withAlphaComponent(0.5) : UIColor.clear
        let cornerRadius : CGFloat = isShimmering ? 8 : 0
        let isHidden = isShimmering
        
        self.profileView.backgroundColor = backgroundColor
        self.authorNameLabel.backgroundColor = backgroundColor
        self.authorNameLabel.setRadius(all: cornerRadius)
        self.publishDateLabel.backgroundColor = backgroundColor
        self.publishDateLabel.setRadius(all: cornerRadius)
        self.tagContainerView.isHidden = isHidden
        self.thumbnailImageView.backgroundColor = backgroundColor
        self.titleLabel.backgroundColor = backgroundColor
        self.titleLabel.setRadius(all: cornerRadius)
        self.sereyValueContainerView.isHidden = isHidden
        self.upVoteContainerView.isHidden = isHidden
        self.downVoteContainerView.isHidden = isHidden
        self.commentContainerView.isHidden = isHidden
        
        DispatchQueue.main.async {
            self.vwShimmer.isShimmering = isShimmering
        }
    }
}

// MARK: - SetUp RxObservers
extension PostTableViewCell {
    
    func setUpControlsObservers() {
        self.moreButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.cellModel?.onMoreButtonPressed()
            }) ~ self.disposeBag
        
        self.categoryGesture?.rx.event.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.cellModel?.onCategoryPressed()
            }).disposed(by: self.disposeBag)
        
        self.profileViewGesture?.rx.event.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.cellModel?.onProfilePressed()
            }).disposed(by: self.disposeBag)
        
        self.profileLabelGesture?.rx.event.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.cellModel?.onProfilePressed()
            }).disposed(by: self.disposeBag)
    }
}
