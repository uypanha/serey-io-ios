//
//  ChooseCategorySheetViewController.swift
//  SereyIO
//
//  Created by Phanha Uy on 2/6/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class ChooseCategorySheetViewController: BaseViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var allButton: UIButton!
    
    var backgroundGesture: UITapGestureRecognizer? {
        didSet {
//            guard let guesture = self.backgroundGesture else { return }
//
//            guesture.cancelsTouchesInView = false
//            view.addGestureRecognizer(guesture)
//            guesture.rx.event.asObservable()
//                .subscribe(onNext: { [weak self] _ in
//                    self?.dismiss(animated: true, completion: nil)
//                }).disposed(by: self.disposeBag)
        }
    }
    
    var viewModel: ChooseCategorySheetViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
        setUpRxObservers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        containerView.roundCorners(corners: [.topLeft, .topRight], radius: 8)
    }
}

// MARK: - Preparations & Tools
extension ChooseCategorySheetViewController {
    
    func setUpViews() {
        self.backgroundGesture = UITapGestureRecognizer()
        self.titleContainerView.addBorders(edges: [.bottom], color: ColorName.border.color)
        
        prepareTableView()
    }
    
    func prepareTableView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        
        self.tableView.register(PostCategoryTableViewCell.self)
    }
}

// MARK: - SetUp RxObservers
extension ChooseCategorySheetViewController {
    
    func setUpRxObservers() {
        setUpContentChangedObservers()
        setUpShouldPresentObservers()
        
        self.allButton.rx.tap.asObservable()
            .map { ChooseCategorySheetViewModel.Action.allCategoryPressed }
            ~> self.viewModel.didActionSubject
            ~ self.disposeBag
    }
    
    func setUpContentChangedObservers() {
        self.viewModel.cells.asObservable()
            .bind(to: self.tableView.rx.items){ tableView, index, item in
                switch item {
                case is PostCategoryCellViewModel:
                    let cell: PostCategoryTableViewCell = tableView.dequeueReusableCell(forIndexPath: IndexPath(row: index, section: 0))
                    cell.cellModel = item as? PostCategoryCellViewModel
                    return cell
                default:
                    return UITableViewCell()
                }
            } ~ self.disposeBag
    }
    
    func setUpShouldPresentObservers() {
        self.viewModel.shouldPresent.asObservable()
            .subscribe(onNext: { [weak self] viewToPresent in
                switch viewToPresent {
                case .dismiss:
                    self?.dismiss(animated: true, completion: nil)
                }
            }) ~ self.disposeBag
    }
}
