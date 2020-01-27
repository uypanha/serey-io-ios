//
//  NibView.swift
//  iOSTemplate
//
//  Created by Phanha Uy on 9/15/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit
import RxSwift

protocol NibLoadableView: class {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    
    static var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}


class NibView: UIView {
    
    var disposeBag: DisposeBag
    var view: UIView!
    
    override init(frame: CGRect) {
        self.disposeBag = DisposeBag()
        super.init(frame: frame)
        
        // Setup view from .xib file
        self.xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.disposeBag = DisposeBag()
        super.init(coder: aDecoder)
        
        // Setup view from .xib file
        self.xibSetup()
    }
    
    func xibSetup() {
        self.backgroundColor = UIColor.clear
        self.view = self.loadNib()
        // use bounds not frame or it'll be offset
        self.view.frame = bounds
        // Adding custom subview on top of our view
        self.addSubview(self.view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[childView]|",
                                                           options: [],
                                                           metrics: nil,
                                                           views: ["childView": view]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[childView]|",
                                                           options: [],
                                                           metrics: nil,
                                                           views: ["childView": view]))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.view.frame = self.bounds
        self.styleUI()
    }
    
    open func styleUI() {
    }
}

extension NibView: NibLoadableView {
    
    /** Loads instance from nib with the same name. */
    func loadNib() -> UIView {
        let nib = UINib(nibName: type(of: self).nibName, bundle: nil)
        return nib.instantiate(withOwner: self, options: nil).first as! UIView
    }
}
