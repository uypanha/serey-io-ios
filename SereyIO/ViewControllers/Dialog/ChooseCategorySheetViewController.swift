//
//  ChooseCategorySheetViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding
import RxDataSources
import AlignedCollectionViewFlowLayout

class ChooseCategorySheetViewController: BaseCollectionViewController {
    
    lazy var dataSource: RxCollectionViewSectionedReloadDataSource<SectionItem> = { [unowned self] in
        return self.prepreDataSource()
    }()
    
    var viewModel: ChooseCategorySheetViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
}

// MARK: - Preparations & Tools
extension ChooseCategorySheetViewController {
    
    func setUpViews() {
        self.view.backgroundColor = .white
        setUpCollectionView()
    }
    
    func setUpCollectionView() {
        self.collectionView.backgroundColor = .clear
        self.collectionView.contentInset = .init(top: 0, left: 24, bottom: 24, right: 24)
        let flowLayout = (self.collectionView.collectionViewLayout as? AlignedCollectionViewFlowLayout)
        flowLayout?.horizontalAlignment = .left
        flowLayout?.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout?.itemSize = UICollectionViewFlowLayout.automaticSize
        flowLayout?.minimumLineSpacing = 12
        flowLayout?.minimumInteritemSpacing = 12
        flowLayout?.sectionInset = .init(top: 4, left: 0, bottom: 16 + self.bottomSafeAreaHeight, right: 0)
        self.collectionView.register(FilterHeaderCollectionViewCell.self)
        self.collectionView.register(HeaderCollectionViewCell.self)
        self.collectionView.register(ProductCategoryCollectionViewCell.self, forCellWithReuseIdentifier: "MDCChipCollectionViewCell")
    }
    
    func prepreDataSource() -> RxCollectionViewSectionedReloadDataSource<SectionItem> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionItem>(configureCell: { (datasource, collectionView, indexPath, item) -> UICollectionViewCell in
            switch item {
            case is FilterHeaderCellViewModel:
                let cell: FilterHeaderCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                cell.updateSize(UIScreen.main.bounds.size)
                cell.cellModel = item as? FilterHeaderCellViewModel
                return cell
            case is HeaderCellViewModel:
                let cell: HeaderCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
                cell.cellModel = item as? HeaderCellViewModel
                cell.updateSize(UIScreen.main.bounds.size)
                return cell
            case is ProductCategoryCellViewModel:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MDCChipCollectionViewCell", for: indexPath) as! ProductCategoryCollectionViewCell
                cell.chipView.primaryStyle()
                cell.cellModel = item as? ProductCategoryCellViewModel
                return cell
            default:
                return UICollectionViewCell()
            }
        })
        
        return dataSource
    }
}

// MARK: - SetUp RxObservers
extension ChooseCategorySheetViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpControlObservers()
        setUpViewToPresentObservers()
    }
    
    func setUpControlObservers() {
        self.collectionView.rx.itemSelected.asObservable()
            .map { ChooseCategorySheetViewModel.Action.itemSelected($0) }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.collectionView.rx.items(dataSource: self.dataSource))
            ~ self.disposeBag
    }
    
    func setUpViewToPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                }
            }) ~ self.disposeBag
    }
}
