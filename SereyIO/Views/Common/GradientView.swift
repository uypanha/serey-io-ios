//
//  GradientView.swift
//  Togness
//
//  Created by Phanha Uy on 12/17/19.
//  Copyright © 2019 Phanha Uy. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {
    
    @IBInspectable var colors: [UIColor] = [UIColor.darkGray, UIColor.lightGray] {
        didSet {
            reloadView()
        }
    }
    
    var startPoint: CAGradientLayer.Point = .topCenter {
        didSet {
            reloadView()
        }
    }
    
    var endPoint: CAGradientLayer.Point = .bottomCenter {
        didSet {
            reloadView()
        }
    }
    
    private var gradientLayer: CAGradientLayer?
    
    fileprivate func reloadView() {
        configureGradientView()
    }
    
    fileprivate func configureGradientView() {
        self.gradientLayer?.removeFromSuperlayer()
        
        self.gradientLayer = CAGradientLayer(start: startPoint, end: endPoint, colors: colors.map { $0.cgColor }, type: .radial)
        self.gradientLayer?.frame = self.bounds
        self.layer.addSublayer(self.gradientLayer!)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.gradientLayer?.frame = self.bounds
    }
}

// MARK: - CAGradientLayer Extension
extension CAGradientLayer {
    
    enum Point {
        case topLeft
        case centerLeft
        case bottomLeft
        case topCenter
        case center
        case bottomCenter
        case topRight
        case centerRight
        case bottomRight
        case custom(x: Double, y: Double)
        
        var point: CGPoint {
            switch self {
            case .topLeft:
                return CGPoint(x: 0, y: 0)
            case .centerLeft:
                return CGPoint(x: 0, y: 0.5)
            case .bottomLeft:
                return CGPoint(x: 0, y: 1.0)
            case .topCenter:
                return CGPoint(x: 0.5, y: 0)
            case .center:
                return CGPoint(x: 0.5, y: 0.5)
            case .bottomCenter:
                return CGPoint(x: 0.5, y: 1.0)
            case .topRight:
                return CGPoint(x: 1.0, y: 0.0)
            case .centerRight:
                return CGPoint(x: 1.0, y: 0.5)
            case .bottomRight:
                return CGPoint(x: 1.0, y: 1.0)
            case .custom(let x, let y):
                return CGPoint(x: x, y: y)
            }
        }
    }
    
    convenience init(start: Point, end: Point, colors: [CGColor], type: CAGradientLayerType) {
        self.init()
        self.startPoint = start.point
        self.endPoint = end.point
        self.colors = colors
        self.locations = (0..<colors.count).map(NSNumber.init)
    }
}
