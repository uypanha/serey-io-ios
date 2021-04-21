//
//  PostCategoryTableViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/18/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class PostCategoryTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var cellModel: PostCategoryCellViewModel? {
        didSet {
            guard let cellModel = self.cellModel else { return }
            
            cellModel.nameText ~> self.categoryNameLabel.rx.text ~ self.disposeBag
            self.setUpCellModelObservers(cellModel)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        setUpViews()
    }
}

// MARK: - Preparations & Tools
extension PostCategoryTableViewCell {
    
    func setUpViews() {
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: 1, height: 1)
            layout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        self.collectionView.register(SubPostCategoryCollectionViewCell.self)
    }
    
    func setUpCellModelObservers(_ cellModel: PostCategoryCellViewModel) {
        cellModel.cells.asObservable()
            .bind(to: self.collectionView.rx.items) { collectionView, index, item in
                switch item {
                case is CategoryCellViewModel:
                    let cell: SubPostCategoryCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: IndexPath(row: index, section: 0))
                    cell.cellModel = item as? CategoryCellViewModel
                    return cell
                default:
                    return UICollectionViewCell()
                }
        } ~ self.disposeBag
        
        self.collectionView.rx.itemSelected.asObservable()
            .map { PostCategoryCellViewModel.Action.itemSelected($0) }
            ~> cellModel.didActionSubject
            ~ self.disposeBag
    }
}
