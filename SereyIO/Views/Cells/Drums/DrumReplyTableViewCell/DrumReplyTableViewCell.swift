//
//  DrumReplyTableViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 25/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then
import SnapKit
import SkeletonView
import RxCocoa
import RxSwift
import RxBinding

class DrumReplyTableViewCell: BaseTableViewCell {
    
    lazy var containerView: UIView = .init()
    
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
    
    lazy var descriptionLabel: UILabel = {
        return .createLabel(14, weight: .medium, textColor: .color(.title)).then {
            $0.numberOfLines = 0
            $0.skeletonTextNumberOfLines = 1
            $0.lastLineFillPercent = 80
            $0.skeletonTextLineHeight = .fixed(14)
            $0.withMinHeight(14)
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
    
    lazy var likeButton: UIButton = {
        return .createButton(with: 0, weight: .regular).then {
            self.prepareActionButton($0, image: R.image.upVoteIcon())
        }
    }()
    
    lazy var likeCount: UILabel = {
        return .createLabel(12, weight: .medium, textColor: .color(.title)).then {
            $0.text = "6"
        }
    }()
    
    var cellModel: DrumReplyCellViewModel? {
        didSet {
            guard let cellModel = cellModel else {
                return
            }

            self.disposeBag ~ [
                cellModel.profileModel ~> self.profileView.rx.profileViewModel,
                cellModel.profileName ~> self.profileNamaLabel.rx.text,
                cellModel.createdAt ~> self.createdAtLabel.rx.text,
                cellModel.descriptionText ~> self.descriptionLabel.rx.text,
                cellModel.likeCount ~> self.likeCount.rx.text,
                cellModel.commentCount ~> self.commentCount.rx.text,
                cellModel.commentCount.map { $0 == nil } ~> self.commentCount.rx.isHidden,
                cellModel.isVoteEnabled ~> self.likeButton.rx.isEnabled,
                cellModel.isShimmering.asObservable()
                    .subscribe(onNext: { [weak self] isShimmering in
                        self?.likeCount.isHidden = isShimmering
                        
                        DispatchQueue.main.async {
                            self?.profileView.setSkeletonView(isShimmering)
                            self?.profileNamaLabel.setSkeletonView(isShimmering)
                            self?.createdAtLabel.setSkeletonView(isShimmering)
                            self?.descriptionLabel.setSkeletonView(isShimmering)
                            self?.commentButton.setSkeletonView(isShimmering)
                            self?.likeButton.setSkeletonView(isShimmering)
                        }
                    })
            ]
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
}

// MARK: - Preparations & Tools
private extension DrumReplyTableViewCell {
    
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
            $0.addArrangedSubview(self.descriptionLabel)
            
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
                $0.addArrangedSubview(UIStackView().then {
                    $0.axis = .horizontal
                    $0.spacing = 6
                    
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
        prepareSkeletonViews()
    }
    
    private func prepareActionButton(_ button: UIButton, image: UIImage?) {
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = .init(top: 6, left: 6, bottom: 6, right: 6)
        self.setButtonAction(button: button, .color("#E1E1E1"))
        button.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
    }
    
    private func setButtonAction(button: UIButton, _ color: UIColor) {
        button.customStyle(with: color)
        button.setRadius(all: 12)
    }
    
    private func prepareSkeletonViews() {
        self.profileView.isSkeletonable = true
        self.profileNamaLabel.isSkeletonable = true
        self.profileNamaLabel.linesCornerRadius = 4
        self.createdAtLabel.isSkeletonable = true
        self.createdAtLabel.linesCornerRadius = 4
        self.descriptionLabel.isSkeletonable = true
        self.descriptionLabel.linesCornerRadius = 4
        self.commentButton.isSkeletonable = true
        self.likeButton.isSkeletonable = true
    }
}
