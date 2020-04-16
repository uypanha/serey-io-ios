//
//  VoteDialogViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 4/16/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

class VoteDialogViewController: BaseViewController {
    
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var voteTitleLabel: UILabel!
    @IBOutlet weak var progressValueLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var viewModel: VoteDialogViewModel!
    
    init() {
        super.init(nibName: R.nib.voteDialogViewController.name, bundle: R.nib.voteDialogViewController.bundle)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpViews()
    }
}

// MARK: - Preparations & Tools
extension VoteDialogViewController {
    
    func setUpViews() {
        self.titleContainerView.addBorders(edges: [.bottom], color: ColorName.border.color)
        self.confirmButton.primaryStyle()
        self.cancelButton.secondaryStyle()
    }
}
