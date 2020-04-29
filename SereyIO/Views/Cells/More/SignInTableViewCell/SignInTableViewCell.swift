//
//  SignInTableViewCell.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/12/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxBinding

class SignInTableViewCell: BaseTableViewCell {
    
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var orRegisterLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    var cellModel: SignInCellViewModel?

    override func prepareForReuse() {
        super.prepareForReuse()
        
        setUpTexts()
        setUpRxObservers()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        setUpTexts()
        setUpRxObservers()
        addBorder(edges: .bottom, color: UIColor.lightGray.withAlphaComponent(0.5), thickness: 1)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.goButton.makeMeCircular()
        self.goButton.setBorder(borderWith: 1, borderColor: UIColor.lightGray)
    }
    
    private func setUpTexts() {
        self.signInLabel.text = R.string.auth.signIn.localized()
        self.orRegisterLabel.text = R.string.auth.orSignUp.localized()
        self.goButton.setTitle(R.string.auth.go.localized(), for: .normal)
    }
}

// MARK: - SetUp RxObservers
fileprivate extension SignInTableViewCell {
    
    func setUpRxObservers() {
        setUpControlsObservers()
    }
    
    func setUpControlsObservers() {
        self.goButton.rx.tap.asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.cellModel?.didAction(with: .signInPressed)
            }) ~ self.disposeBag
    }
}
