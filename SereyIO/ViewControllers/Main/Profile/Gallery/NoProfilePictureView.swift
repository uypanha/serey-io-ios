//
//  NoProfilePictureView.swift
//  SereyIO
//
//  Created by Mäd on 11/01/2022.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit
import Then

class NoProfilePictureView: UIView {
    
    lazy var descriptionLabel: UILabel = {
        return .createLabel(18, weight: .regular, textColor: .init(hexString: "#606060")).then {
            $0.text = "No picture to be selected\nUpload now"
            $0.textAlignment = .center
            $0.numberOfLines = 0
        }
    }()
    
    lazy var uploadButton: UIView = {
        return self.prepareUploadButton()
    }()
    
    var uploadTapRegonizer: UITapGestureRecognizer!
    
    var didUploadPressed: () -> Void = {}
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.prepareViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func uploadPressed() {
        self.didUploadPressed()
    }
}

// MARK: - Preparations & Tools
extension NoProfilePictureView {
    
    func prepareViews() {
        let stackView = UIStackView().then {
            $0.axis = .vertical
            $0.spacing = 20
            $0.alignment = .center
            
            $0.addArrangedSubview(self.descriptionLabel)
            $0.addArrangedSubview(self.uploadButton)
            self.uploadButton.snp.makeConstraints { make in
                make.width.height.equalTo(120)
            }
        }
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func prepareUploadButton() -> UIView {
        let mainView = DashBorderView().then {
            $0.borderColor = UIColor(hexString: "#A7A7A7")
            $0.borderWidth = 3
            $0.cornerRadius = 19
        }
        
        let infoStackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .center
            $0.spacing = 6
            
            let imageView = UIImageView(image: R.image.uploadProfileBigIcon()).then {
                $0.tintColor = UIColor(hexString: "#A7A7A7")
                $0.contentMode = .scaleAspectFit
            }
            $0.addArrangedSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.height.equalTo(48)
            }
            
            let uploadLabel: UILabel = .createLabel(18, weight: .regular, textColor: UIColor(hexString: "#A7A7A7"))
            uploadLabel.text = "Upload"
            $0.addArrangedSubview(uploadLabel)
        }
        mainView.addSubview(infoStackView)
        infoStackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.centerY.equalToSuperview()
        }
        
        self.uploadTapRegonizer = .init(target: self, action: #selector(self.uploadPressed))
        mainView.addGestureRecognizer(self.uploadTapRegonizer)
        mainView.isUserInteractionEnabled = true
        
        return mainView
    }
}
