//
//  DrumsPostTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 21/6/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import RxCocoa
import RxSwift
import RxBinding
import SkeletonView

class DrumsPostTableViewCell: BaseTableViewCell {
    
    lazy var containerView: UIView = .init()
    
    lazy var redrummedView: UIStackView = {
        return .init().then {
            $0.axis = .horizontal
            $0.distribution = .fillProportionally
            $0.spacing = 6
            $0.alignment = .center
            
            let iconImageView = UIImageView(image: R.image.redrumIcon()).then {
                $0.tintColor = .color(.subTitle)
                $0.withSize(.init(width: 12, height: 12))
            }
            $0.addArrangedSubview(iconImageView)
            $0.addArrangedSubview(self.redrummedByLabel)
        }
    }()
    
    lazy var redrummedByLabel: UILabel = {
        return .createLabel(12, weight: .regular, textColor: .color(.subTitle))
    }()
    
    lazy var profileView: ProfileView = .init(frame: .init())
    lazy var profileNamaLabel: UILabel = {
        return .createLabel(14, weight: .medium, textColor: .color(.primary)).then {
            $0.withMinHeight(14)
            $0.lastLineFillPercent = 100
            $0.skeletonTextLineHeight = .fixed(14)
        }
    }()
    
    lazy var createdAtLabel: UILabel = {
        return .createLabel(12, weight: .regular, textColor: .color("#878787")).then {
            $0.withMinHeight(12)
            $0.lastLineFillPercent = 30
            $0.skeletonTextLineHeight = .fixed(12)
        }
    }()
    
    lazy var titleLabel: UILabel = {
        return .createLabel(14, weight: .medium, textColor: .color(.title)).then {
            $0.numberOfLines = 0
            $0.skeletonTextNumberOfLines = 1
            $0.lastLineFillPercent = 80
            $0.skeletonTextLineHeight = .fixed(14)
            $0.withMinHeight(14)
        }
    }()
    
    var collectionContainerView: UIStackView!
    var collectionHeightConstraint: ConstraintMakerEditable!
    lazy var collectionView: ContentSizedCollectionView = {
        return .init(frame: .init(), collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.minimumLineSpacing = 6
            $0.minimumInteritemSpacing = 6
            $0.scrollDirection = .vertical
        }).then {
            $0.isScrollEnabled = false
            $0.backgroundColor = .clear
            
            $0.register(DrumImageCollectionViewCell.self, isNib: false)
            $0.register(QuotedDrumCollectionViewCell.self, isNib: false)
        }
    }()
    
    lazy var commentButton: UIButton = {
        return .createButton(with: 0, weight: .regular).then {
            self.prepareActionButton($0, image: R.image.commentDrumIcon())
        }
    }()
    
    lazy var commentCount: UILabel = {
        return .createLabel(12, weight: .medium, textColor: .color(.title)).then {
            $0.text = "1"
        }
    }()
    
    lazy var redrumButton: UIButton = {
        return .createButton(with: 0, weight: .regular).then {
            self.prepareActionButton($0, image: R.image.redrumIcon())
        }
    }()
    
    lazy var likeButton: UIButton = {
        return .createButton(with: 0, weight: .regular).then {
            self.prepareActionButton($0, image: R.image.upVoteIcon())
        }
    }()
    
    lazy var loadingIndicatorView: UIActivityIndicatorView = .init(frame: .init()).then {
        $0.withSize(.init(width: 24, height: 24))
    }
    
    lazy var likeCount: UILabel = {
        return .createLabel(12, weight: .medium, textColor: .color(.title)).then {
            $0.text = "6"
        }
    }()
    
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
            
            self.profileNamaLabel.isUserInteractionEnabled = true
            self.profileNamaLabel.addGestureRecognizer(gesture)
        }
    }
    
    var cellModel: DrumsPostCellViewModel? {
        didSet {
            guard let cellModel = cellModel else {
                return
            }

            self.disposeBag ~ [
                cellModel.redrummedBy ~> self.redrummedByLabel.rx.text,
                cellModel.redrummedBy.map { $0 == nil } ~> self.redrummedView.rx.isHidden,
                cellModel.profileModel ~> self.profileView.rx.profileViewModel,
                cellModel.profileName ~> self.profileNamaLabel.rx.text,
                cellModel.createdAt ~> self.createdAtLabel.rx.text,
                cellModel.title ~> self.titleLabel.rx.text,
                cellModel.likeCount ~> self.likeCount.rx.text,
                cellModel.commentCount ~> self.commentCount.rx.text,
                cellModel.commentCount.map { $0 == nil } ~> self.commentCount.rx.isHidden,
                cellModel.isVoteEnabled ~> self.likeButton.rx.isEnabled,
                cellModel.cells.asObservable().map { $0.isEmpty }
                    .subscribe(onNext: { [weak self] isEmpty in
                        self?.collectionContainerView.isHidden = isEmpty
                        self?.layoutIfNeeded()
                    }),
                cellModel.isShimmering.asObservable()
                    .subscribe(onNext: { [weak self] isShimmering in
                        self?.likeCount.isHidden = isShimmering
                        DispatchQueue.main.async {
                            self?.profileView.setSkeletonView(isShimmering)
                            self?.profileNamaLabel.setSkeletonView(isShimmering)
                            self?.createdAtLabel.setSkeletonView(isShimmering)
                            self?.titleLabel.setSkeletonView(isShimmering)
                            self?.commentButton.setSkeletonView(isShimmering)
                            self?.redrumButton.setSkeletonView(isShimmering)
                            self?.likeButton.setSkeletonView(isShimmering)
                        }
                    })
            ]
            
            cellModel.isLoggedUserRedrummed.asObservable()
                .subscribe(onNext: { [unowned self] isRedrummed in
                    let backgroundColor: UIColor = isRedrummed ? .color("#7FBBE7") : .color("#E1E1E1")
                    let tintColor: UIColor = isRedrummed ? .white : .black
                    self.setButtonAction(button: self.redrumButton, tintColor: tintColor, backgroundColor)
                }) ~ self.disposeBag
            
            cellModel.isLoggedUserVoted.asObservable()
                .subscribe(onNext: { [unowned self] isVoted in
                    let backgroundColor: UIColor = isVoted ? .color("#7FBBE7") : .color("#E1E1E1")
                    let tintColor: UIColor = isVoted ? .white : .black
                    self.setButtonAction(button: self.likeButton, tintColor: tintColor, backgroundColor)
                }) ~ self.disposeBag
            
            cellModel.cells.asObservable()
                .bind(to: self.collectionView.rx.items) { collectionView, index, item in
                    let indexPath = IndexPath(row: index, section: 0)
                    switch item {
                    case is ImageCellViewModel:
                        let cell: DrumImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                        cell.cellModel = item as? ImageCellViewModel
                        cell.updateSize(cellModel.size(forCell: indexPath, maxWidth: self.collectionView.frame.width))
                        return cell
                    case is QuotedDrumCellViewModel:
                        let cell: QuotedDrumCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                        cell.cellModel = item as? QuotedDrumCellViewModel
                        cell.updateSize(cellModel.size(forCell: indexPath, maxWidth: self.collectionView.frame.width))
                        return cell
                    default:
                        return .init()
                    }
                }.disposed(by: self.disposeBag)
            
            self.profileViewGesture?.rx.event.asObservable()
                .subscribe(onNext: { [weak cellModel] _ in
                    cellModel?.didAction(with: .profilePressed)
                }).disposed(by: self.disposeBag)
            
            self.profileLabelGesture?.rx.event.asObservable()
                .subscribe(onNext: { [weak cellModel] _ in
                    cellModel?.didAction(with: .profilePressed)
                }).disposed(by: self.disposeBag)
            
            self.commentButton.rx.tap.asObservable()
                .map { DrumsPostCellViewModel.Action.commentPressed }
                ~> cellModel.didActionSubject
                ~ self.disposeBag
            
            self.redrumButton.rx.tap.asObservable()
                .map { DrumsPostCellViewModel.Action.redrumQuotePressed }
                ~> cellModel.didActionSubject
                ~ self.disposeBag
            
            self.likeButton.rx.tap.asObservable()
                .map { DrumsPostCellViewModel.Action.votePressed }
                ~> cellModel.didActionSubject
                ~ self.disposeBag
            
            self.collectionView.rx.itemSelected.asObservable()
                .map { DrumsPostCellViewModel.Action.itemSelected($0) }
                ~> cellModel.didActionSubject
                ~ self.disposeBag
            
            cellModel.isVoting.asObservable()
                .subscribe(onNext: { [weak self] voteType in
                    self?.loadingIndicatorView.isHidden = voteType == nil
                    self?.likeButton.isHidden = voteType == .upvote
                    if voteType != nil {
                        self?.loadingIndicatorView.startAnimating()
                    }
                }) ~ self.disposeBag
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpLayout()
    }
    
    func shouldUpdateCollectionViewHeight(_ width: CGFloat? = nil) {
        let height = self.cellModel?.minHeight(with: width ?? self.collectionView.frame.height) ?? 100
        self.collectionHeightConstraint.constraint.update(offset: height).activate()
    }
}

// MARK: - Preparations & Tools
extension DrumsPostTableViewCell {
    
    func setUpLayout() {
        let cardView = CardView(false)
        cardView.borderColor = .color("#F1F1F1")
        cardView.borderWidth = 1
        cardView.cornerRadius = 20
        
        cardView.addSubview(self.containerView)
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        let mainStactView = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fillProportionally
            $0.spacing = 16
            
            $0.addArrangedSubview(self.redrummedView)
            
            let profileStackView = UIStackView().then {
                $0.axis = .horizontal
                $0.distribution = .fillProportionally
                $0.alignment = .center
                $0.spacing = 12
                $0.withHeight(43)
                
                self.profileView.withSize(.init(width: 43, height: 43))
                $0.addArrangedSubview(self.profileView)
                
                let profileInfoStackView = UIStackView().then {
                    $0.axis = .vertical
                    $0.spacing = 2
                    $0.distribution = .fillProportionally
                    
                    $0.addArrangedSubview(self.profileNamaLabel)
                    $0.addArrangedSubview(self.createdAtLabel)
                }
                $0.addArrangedSubview(profileInfoStackView)
            }
            $0.addArrangedSubview(profileStackView)
            $0.addArrangedSubview(self.titleLabel)
            self.collectionContainerView = UIStackView().then {
                $0.addArrangedSubview(self.collectionView)
                
                $0.snp.makeConstraints { make in
                    self.collectionHeightConstraint = make.height.greaterThanOrEqualTo(100)
                }
            }
            $0.addArrangedSubview(self.collectionContainerView)
            self.collectionView.snp.makeConstraints { make in
                make.height.greaterThanOrEqualTo(60)
            }
            
            let buttonStackView = UIStackView().then {
                $0.axis = .horizontal
                $0.spacing = 13
                $0.distribution = .fill
                $0.withHeight(24)
                
                $0.addArrangedSubview(UIStackView().then {
                    $0.axis = .horizontal
                    $0.spacing = 6
                    
                    $0.addArrangedSubview(self.commentButton)
                    $0.addArrangedSubview(self.commentCount)
                })
                $0.addArrangedSubview(self.redrumButton)
                $0.addArrangedSubview(UIStackView().then {
                    $0.axis = .horizontal
                    $0.spacing = 6
                    
                    $0.addArrangedSubview(self.loadingIndicatorView)
                    $0.addArrangedSubview(self.likeButton)
                    $0.addArrangedSubview(self.likeCount)
                })
                $0.addArrangedSubview(UIStackView())
            }
            $0.addArrangedSubview(buttonStackView)
        }
        self.containerView.addSubview(mainStactView)
        mainStactView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.selectionStyle = .none
        self.prepareSkeletonViews()
        
        self.profileViewGesture = .init()
        self.profileLabelGesture = .init()
        
        let layout = collectionView.collectionViewLayout
        if let flowLayout = layout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = .init(width: self.collectionView.frame.width, height: 100)
        }
    }
    
    private func prepareActionButton(_ button: UIButton, image: UIImage?) {
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = .init(top: 6, left: 6, bottom: 6, right: 6)
        self.setButtonAction(button: button, tintColor: .black, .color("#E1E1E1"))
        button.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
    }
    
    private func prepareSkeletonViews() {
        self.profileView.isSkeletonable = true
        self.profileNamaLabel.isSkeletonable = true
        self.profileNamaLabel.linesCornerRadius = 4
        self.createdAtLabel.isSkeletonable = true
        self.createdAtLabel.linesCornerRadius = 4
        self.titleLabel.isSkeletonable = true
        self.titleLabel.linesCornerRadius = 4
        self.commentButton.isSkeletonable = true
        self.redrumButton.isSkeletonable = true
        self.likeButton.isSkeletonable = true
    }
    
    private func setButtonAction(button: UIButton, tintColor: UIColor, _ color: UIColor) {
        button.tintColor = tintColor
        button.customStyle(with: color)
        button.setRadius(all: 12)
    }
}
