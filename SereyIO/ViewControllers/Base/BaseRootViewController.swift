//
//  BaseRootViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 6/29/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit

open class BaseRootViewController: UIViewController {
    
    var currentViewController: UIViewController
    
    init(_ initialViewController: UIViewController) {
        self.currentViewController = initialViewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.presentViewController(viewController: self.currentViewController)
    }
}

// MARK: - Preparations & Tools
extension BaseRootViewController {
    
    internal func presentViewController(viewController: UIViewController) {
        self.addChild(viewController)
        viewController.view.frame = self.view.bounds
        self.view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    internal func changeCurrentViewController(newViewController: UIViewController) {
        
        self.currentViewController.willMove(toParent: nil)
        self.currentViewController.view.removeFromSuperview()
        self.currentViewController.removeFromParent()
        
        self.currentViewController = newViewController
    }
    
    internal func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil) {
        new.view.frame = self.view.bounds
        self.currentViewController.willMove(toParent: nil)
        self.addChild(new)
        
        let moveFrom = self.currentViewController
        self.currentViewController = new
        
        transition(from: moveFrom, to: new, duration: 0.3, options: [.transitionCrossDissolve, .curveEaseOut], animations: {
        }) { completed in
            moveFrom.view.removeFromSuperview()
            moveFrom.removeFromParent()
            
            new.didMove(toParent: self)
            completion?()
        }
    }
    
    internal func animateSlideToTopTransition(to newController: UIViewController, completion: (() -> Void)? = nil) {
        let initialFrame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height)
        self.currentViewController.willMove(toParent: nil)
        self.addChild(newController)
        
        let moveFrom = self.currentViewController
        self.currentViewController = newController
        
        newController.view.frame = initialFrame
        
        transition(from: moveFrom, to: newController, duration: 0.3, options: [], animations: {
            newController.view.frame = self.view.bounds
        }) { completed in
            moveFrom.view.removeFromSuperview()
            moveFrom.removeFromParent()
            
            newController.didMove(toParent: self)
            completion?()
        }
    }
}
