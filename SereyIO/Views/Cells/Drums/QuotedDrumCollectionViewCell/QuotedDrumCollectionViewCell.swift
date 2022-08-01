//
//  QuotedDrumCollectionViewCell.swift
//  SereyIO
//
//  Created by Panha Uy on 15/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Then
import SnapKit
import MaterialComponents

class QuotedDrumCollectionViewCell: BaseCollectionViewCell {
    
    lazy var containerView: CardView = {
        return .init(false).then {
            $0.borderColor = .color(.border)
            $0.borderWidth = 1
            $0.cornerRadius = 18
        }
    }()
    
    lazy var profileView: ProfileView = .init(frame: .init())
    lazy var profileNamaLabel: UILabel = {
        return .createLabel(12, weight: .medium, textColor: .color(.primary)).then {
            $0.withMinHeight(12)
        }
    }()
    
    lazy var createdAtLabel: UILabel = {
        return .createLabel(12, weight: .regular, textColor: .color("#878787")).then {
            $0.withMinHeight(12)
        }
    }()
    
    lazy var descriptionLabel: UILabel = {
        return .createLabel(12, weight: .regular, textColor: .color("#414141")).then {
            $0.numberOfLines = 0
        }
    }()
    
    var collectionContainerView: UIStackView!
    var collectionHeightConstraint: ConstraintMakerEditable!
    lazy var collectionView: UICollectionView = {
        return .init(frame: .init(), collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.minimumLineSpacing = 6
            $0.minimumInteritemSpacing = 6
            $0.scrollDirection = .vertical
        }).then {
            $0.isScrollEnabled = false
            $0.delegate = self
            
            $0.register(ImageCollectionViewCell.self, isNib: false)
            $0.snp.makeConstraints { make in
                self.collectionHeightConstraint = make.height.greaterThanOrEqualTo(100)
            }
        }
    }()
    
    var collectionViewWidth: CGFloat = 100
    var widthConstraint: ConstraintMakerEditable!
    
    var rippleController: MDCRippleTouchController!
    
    var cellModel: QuotedDrumCellViewModel? {
        didSet {
            guard let cellModel = cellModel else {
                return
            }

            self.disposeBag ~ [
                cellModel.profileModel ~> self.profileView.rx.profileViewModel,
                cellModel.profileName.map { "\($0 ?? "") |" } ~> self.profileNamaLabel.rx.text,
                cellModel.createdAt ~> self.createdAtLabel.rx.text,
                cellModel.descriptionText ~> self.descriptionLabel.rx.text,
                cellModel.cells.asObservable().map { $0.isEmpty }
                    .subscribe(onNext: { [weak self] isEmpty in
                        self?.collectionContainerView.isHidden = isEmpty
                    })
            ]
            
            cellModel.cells.asObservable()
                .bind(to: self.collectionView.rx.items) { collectionView, index, item in
                    let indexPath = IndexPath(row: index, section: 0)
                    switch item {
                    case is ImageCellViewModel:
                        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                        cell.cellModel = item as? ImageCellViewModel
                        cell.updateSize(cellModel.size(forCell: indexPath, maxWidth: self.collectionViewWidth))
                        return cell
                    default:
                        return .init()
                    }
                }.disposed(by: self.disposeBag)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setUpLayout()
    }
    
    func updateSize(_ size: CGSize) {
        self.widthConstraint.constraint.update(offset: size.width).activate()
        
        self.collectionViewWidth = size.width - 24
        let height = self.cellModel?.maxHeight(with: self.collectionViewWidth) ?? 50
        self.collectionHeightConstraint.constraint.update(offset: height).activate()
    }
}

// MARK: - Preparations & Tools
private extension QuotedDrumCollectionViewCell {
    
    func setUpLayout() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubview(self.containerView)
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            self.widthConstraint = make.width.equalTo(200)
        }
        
        let mainStackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 16
            $0.distribution = .fillProportionally
            
            let profileStackView = UIStackView().then {
                $0.axis = .horizontal
                $0.distribution = .fill
                $0.alignment = .center
                $0.spacing = 12
                $0.withHeight(24)
                
                self.profileView.withSize(.init(width: 24, height: 24))
                $0.addArrangedSubview(self.profileView)
                
                let profileInfoStackView = UIStackView().then {
                    $0.axis = .horizontal
                    $0.spacing = 2
                    $0.distribution = .fill
                    
                    $0.addArrangedSubview(self.profileNamaLabel)
                    $0.addArrangedSubview(self.createdAtLabel)
                }
                $0.addArrangedSubview(profileInfoStackView)
                $0.addArrangedSubview(UIStackView())
            }
            $0.addArrangedSubview(profileStackView)
            $0.addArrangedSubview(self.descriptionLabel)
            self.collectionContainerView = .init().then {
                $0.addArrangedSubview(self.collectionView)
            }
            $0.addArrangedSubview(self.collectionContainerView)
        }
        
        self.containerView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        self.rippleController = .init(view: self.containerView)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension QuotedDrumCollectionViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.cellModel?.size(forCell: indexPath, maxWidth: self.collectionViewWidth) ?? .init()
    }
}
