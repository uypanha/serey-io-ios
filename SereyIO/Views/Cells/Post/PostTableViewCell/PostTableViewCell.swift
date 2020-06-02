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
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
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
    
    private var upVoteGesture: UITapGestureRecognizer? {
        didSet {
            guard let gesture = self.upVoteGesture else { return }
            
            self.upVoteContainerView.isUserInteractionEnabled = true
            self.upVoteContainerView.addGestureRecognizer(gesture)
        }
    }
    
    private var downVoteGesture: UITapGestureRecognizer? {
        didSet {
            guard let gesture = self.downVoteGesture else { return }
            
            self.downVoteContainerView.isUserInteractionEnabled = true
            self.downVoteContainerView.addGestureRecognizer(gesture)
        }
    }
    
    var cellModel: PostCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            let imageOptions: KingfisherOptionsInfo = [
                .processor(DownsamplingImageProcessor(size: self.thumbnailImageView.frame.size)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage
            ]
            
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
                    .bind(to: self.thumbnailImageView.kf.rx.image(placeholder: ViewUtiliesHelper.prepareDefualtPlaceholder(), options: imageOptions)),
                cellModel.isMoreHidden ~> self.moreButton.rx.isHidden,
                cellModel.votedType.asObservable()
                    .subscribe(onNext: { [weak self] voteType in
                        self?.preparepVoteTypeStyle(voteType)
                    }),
                cellModel.upVoteEnabled ~> self.upVoteContainerView.rx.isUserInteractionEnabled,
                cellModel.flagEnabled ~> self.downVoteContainerView.rx.isUserInteractionEnabled,
                cellModel.isVoting.asObservable()
                    .subscribe(onNext: { [unowned self] voteType in
                        self.upVoteContainerView.isHidden = voteType == .upvote
                        self.downVoteContainerView.isHidden = voteType == .flag
                        self.loadingIndicator.isHidden = voteType == nil
                        if voteType != nil {
                            self.loadingIndicator.startAnimating()
                        }
                    })
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
        self.upVoteGesture = UITapGestureRecognizer()
        self.downVoteGesture = UITapGestureRecognizer()
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
    
    func preparepVoteTypeStyle(_ voteType: VotedType?) {
        let downVoteTintColor: UIColor = voteType == .flag ? ColorName.primary.color : .lightGray
        let downVoteIcon: UIImage? = voteType == .flag ? R.image.downVoteFilledIcon() : R.image.downVoteIcon()
        self.downVoteImageView.tintColor = downVoteTintColor
        self.downVoteCountLabel.textColor = downVoteTintColor
        self.downVoteImageView.image = downVoteIcon
        
        let upVoteTintColor: UIColor = voteType == .upvote ? ColorName.primary.color : .lightGray
        let upVoteIcon: UIImage? = voteType == .upvote ? R.image.upVoteFilledIcon() : R.image.upVoteIcon()
        self.upVoteImageView.tintColor = upVoteTintColor
        self.upVoteCountLabel.textColor = upVoteTintColor
        self.upVoteImageView.image = upVoteIcon
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
        
        self.upVoteGesture?.rx.event.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.cellModel?.didUpvotePressed()
            }).disposed(by: self.disposeBag)
        
        self.downVoteGesture?.rx.event.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.cellModel?.didFlagPressed()
            }).disposed(by: self.disposeBag)
    }
}
