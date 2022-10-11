//
//  CommentTableViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/9/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Shimmer

class CommentTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var vwShimmer: FBShimmeringView!
    
    @IBOutlet weak var profileView: ProfileView!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var actionContainerView: UIStackView!
    @IBOutlet weak var sereyValueContainerView: UIStackView!
    @IBOutlet weak var sereySymbolImageView: UIImageView!
    @IBOutlet weak var sereyValueLabel: UILabel!
    
    @IBOutlet weak var voteContainerView: UIStackView!
    @IBOutlet weak var upVoteContainerView: UIStackView!
    @IBOutlet weak var upVoteImageView: UIImageView!
    @IBOutlet weak var upVoteCountLabel: UILabel!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var downVoteContainerView: UIStackView!
    @IBOutlet weak var downVoteImageView: UIImageView!
    @IBOutlet weak var downVoteCountLabel: UILabel!
    
    @IBOutlet weak var commentContainerView: UIStackView!
    @IBOutlet weak var viewConversationButton: UIButton!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    
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
    
    private var replyCommentGesture: UITapGestureRecognizer? {
        didSet {
            guard let gesture = self.replyCommentGesture else { return }
            
            self.commentContainerView.isUserInteractionEnabled = true
            self.commentContainerView.addGestureRecognizer(gesture)
        }
    }
    
    var cellModel: CommentCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            self.disposeBag ~ [
                cellModel.profileViewModel ~> self.profileView.rx.profileViewModel,
                cellModel.authorName ~> self.authorNameLabel.rx.text,
                cellModel.publishedAt ~> self.publishDateLabel.rx.text,
                cellModel.contentAttributedString ~> self.descriptionLabel.rx.attributedText,
                cellModel.sereyValue ~> self.sereyValueLabel.rx.text,
                cellModel.upVoteCount ~> self.upVoteCountLabel.rx.text,
                cellModel.downVoteCount ~> self.downVoteCountLabel.rx.text,
                cellModel.conversationText ~> self.viewConversationButton.rx.title(for: .normal),
                cellModel.isViewConversationHidden ~> self.viewConversationButton.rx.isHidden,
                cellModel.isReplyHidden ~> self.commentContainerView.rx.isHidden,
                cellModel.leadingConstraint ~> self.leadingConstraint.rx.constant,
                cellModel.isVoteAllowed.map { !$0 } ~> self.voteContainerView.rx.isHidden,
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
            
            setUpRxObservers(cellModel)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.vwShimmer.shimmeringSpeed = 400
        self.vwShimmer.contentView = self.mainView
        self.upVoteGesture = UITapGestureRecognizer()
        self.downVoteGesture = UITapGestureRecognizer()
        self.replyCommentGesture = UITapGestureRecognizer()
    }
}

// MARK: - Preparations & Tools
extension CommentTableViewCell {
    
    private func prepareShimmering(_ isShimmering: Bool) {
        let backgroundColor = isShimmering ? .color(.shimmering).withAlphaComponent(0.5) : UIColor.clear
        let cornerRadius : CGFloat = isShimmering ? 8 : 0
        let isHidden = isShimmering
        
        self.profileView.backgroundColor = backgroundColor
        self.authorNameLabel.backgroundColor = backgroundColor
        self.authorNameLabel.setRadius(all: cornerRadius)
        self.publishDateLabel.backgroundColor = backgroundColor
        self.publishDateLabel.setRadius(all: cornerRadius)
        
        self.descriptionLabel.backgroundColor = backgroundColor
        self.descriptionLabel.setRadius(all: cornerRadius)
        
        self.sereyValueContainerView.isHidden = !Constants.showReward || isHidden
        self.actionContainerView.isHidden = isHidden
        
        DispatchQueue.main.async {
            self.vwShimmer.isShimmering = isShimmering
        }
    }
    
    func preparepVoteTypeStyle(_ voteType: VotedType?) {
        let downVoteTintColor: UIColor = voteType == .flag ? .color(.primary) : .lightGray
        let downVoteIcon: UIImage? = voteType == .flag ? R.image.downVoteFilledIcon() : R.image.downVoteIcon()
        self.downVoteImageView.tintColor = downVoteTintColor
        self.downVoteCountLabel.textColor = downVoteTintColor
        self.downVoteImageView.image = downVoteIcon
        
        let upVoteTintColor: UIColor = voteType == .upvote ? .color(.primary) : .lightGray
        let upVoteIcon: UIImage? = voteType == .upvote ? R.image.upVoteFilledIcon() : R.image.upVoteIcon()
        self.upVoteImageView.tintColor = upVoteTintColor
        self.upVoteCountLabel.textColor = upVoteTintColor
        self.upVoteImageView.image = upVoteIcon
    }
}

// MARK: - SetUp RxObservers
extension CommentTableViewCell {
    
    func setUpRxObservers(_ cellModel: CommentCellViewModel) {
        self.upVoteGesture?.rx.event.asObservable()
            .map { _ in CommentCellViewModel.Action.upVotePressed }
            .bind(to: cellModel.didActionSubject)
            .disposed(by: self.disposeBag)
        
        self.downVoteGesture?.rx.event.asObservable()
            .map { _ in CommentCellViewModel.Action.downVotePressed }
            .bind(to: cellModel.didActionSubject)
            .disposed(by: self.disposeBag)
        
        self.replyCommentGesture?.rx.event.asObservable()
            .map { _ in CommentCellViewModel.Action.replyCommentPressed }
            .bind(to: cellModel.didActionSubject)
            .disposed(by: self.disposeBag)
        
        self.viewConversationButton.rx.tap.asObservable()
            .map { _ in CommentCellViewModel.Action.replyCommentPressed }
            .bind(to: cellModel.didActionSubject)
            .disposed(by: self.disposeBag)
    }
}
