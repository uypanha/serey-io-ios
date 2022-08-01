//
//  DrumDetailView.swift
//  SereyIO
//
//  Created by Panha Uy on 20/7/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import Then
import SnapKit
import SkeletonView
import RichEditorView

class DrumDetailView: UIView {
    
    lazy var disposeBag = DisposeBag()
    lazy var containerView: UIView = .init()
    
    lazy var redrummedView: UIStackView = {
        return .init().then {
            $0.axis = .horizontal
            $0.distribution = .fill
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
    
    var editorHeightConstraint: ConstraintMakerEditable!
    lazy var richEditor: SRichEditorView = {
        return .init(frame: .init()).then {
            $0.isSkeletonable = true
            $0.skeletonCornerRadius = 4
            $0.snp.makeConstraints { make in
                self.editorHeightConstraint = make.height.equalTo(16)
            }
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
            
            $0.register(ImageCollectionViewCell.self, isNib: false)
            $0.register(QuotedDrumCollectionViewCell.self, isNib: false)
        }
    }()
    
    lazy var commentButton: UIButton = {
        return .createButton(with: 0, weight: .regular).then {
            self.prepareActionButton($0, image: R.image.commentDrumIcon())
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
                cellModel.descriptionHtml ~> self.richEditor.rx.html,
                cellModel.likeCount ~> self.likeCount.rx.text,
                cellModel.cells.asObservable().map { $0.isEmpty }
                    .subscribe(onNext: { [weak self] isEmpty in
                        self?.collectionContainerView.isHidden = isEmpty
                        self?.layoutIfNeeded()
                    }),
                cellModel.isShimmering.asObservable()
                    .subscribe(onNext: { [weak self] isShimmering in
                        self?.likeCount.isHidden = isShimmering
                        self?.commentButton.setSkeletonView(isShimmering)
                        self?.redrumButton.setSkeletonView(isShimmering)
                        self?.likeButton.setSkeletonView(isShimmering)
                        
                        DispatchQueue.main.async {
                            self?.profileView.setSkeletonView(isShimmering)
                            self?.richEditor.setSkeletonView(isShimmering)
                            self?.profileNamaLabel.setSkeletonView(isShimmering)
                            self?.createdAtLabel.setSkeletonView(isShimmering)
                        }
                    })
            ]
            
            cellModel.redrumButtonColor.asObservable()
                .subscribe(onNext: { [unowned self] color in
                    self.setButtonAction(button: self.redrumButton, color)
                }) ~ self.disposeBag
            
            cellModel.cells.asObservable()
                .bind(to: self.collectionView.rx.items) { collectionView, index, item in
                    let indexPath = IndexPath(row: index, section: 0)
                    switch item {
                    case is ImageCellViewModel:
                        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
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
            
            self.collectionView.rx.itemSelected.asObservable()
                .map { DrumsPostCellViewModel.Action.itemSelected($0) }
                ~> cellModel.didActionSubject
                ~ self.disposeBag
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
}

// MARK: - Preparations & Tools
extension DrumDetailView {
    
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
                $0.distribution = .fill
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
            $0.addArrangedSubview(self.richEditor)
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
                
                $0.addArrangedSubview(self.commentButton)
                $0.addArrangedSubview(self.redrumButton)
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
        
        self.addSubview(cardView)
        cardView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        self.backgroundColor = .clear
        self.prepareSkeletonViews()
        
        self.profileViewGesture = .init()
        self.profileLabelGesture = .init()
        
        let layout = collectionView.collectionViewLayout
        if let flowLayout = layout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = .init(width: self.collectionView.frame.width, height: 100)
        }
        setUpEditor()
    }
    
    func setUpEditor() {
        richEditor.isScrollEnabled = false
        richEditor.editingEnabled = false
        richEditor.delegate = self
    }
    
    private func prepareActionButton(_ button: UIButton, image: UIImage?) {
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = .init(top: 6, left: 6, bottom: 6, right: 6)
        self.setButtonAction(button: button, .color("#E1E1E1"))
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
        self.richEditor.isSkeletonable = true
        self.commentButton.isSkeletonable = true
        self.redrumButton.isSkeletonable = true
        self.likeButton.isSkeletonable = true
    }
    
    private func setButtonAction(button: UIButton, _ color: UIColor) {
        button.customStyle(with: color)
        button.setRadius(all: 12)
    }
}

// MARK: - RichEditorDelegate
extension DrumDetailView: RichEditorDelegate {
    
    func richEditor(_ editor: RichEditorView, heightDidChange height: Int) {
        self.editorHeightConstraint.constraint.update(offset: CGFloat(height)).activate()
    }
    
    func richEditorDidLoad(_ editor: RichEditorView) {
        editor.customCssAndJS()
        editor.setFontSize(14)
        self.richEditor.editorMargin = 0
        let html = editor.html
        editor.html = html
    }
    
    func richEditor(_ editor: RichEditorView, shouldInteractWith url: URL) -> Bool {
        return false
    }
}
