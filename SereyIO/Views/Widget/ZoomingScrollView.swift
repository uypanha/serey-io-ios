//
//  ZoomingScrollView.swift
//  SereyIO
//
//  Created by Panha Uy on 22/8/22.
//  Copyright © 2022 Serey IO. All rights reserved.
//

import UIKit

class ZoomingScrollView: UIScrollView, UIScrollViewDelegate {
    
    private lazy var doubleTabToZoom: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(self.userDoubleTappedScrollview)).then {
            $0.numberOfTapsRequired = 2
        }
    }()
    
    var doubleTabZoomScale: CGFloat? = nil
    var viewForZooming: UIView? = nil {
        didSet {
            self.delegate = self
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.addGestureRecognizer(self.doubleTabToZoom)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return viewForZooming
    }
    
    @objc func userDoubleTappedScrollview(recognizer:  UITapGestureRecognizer) {
        if (zoomScale > minimumZoomScale) {
            setZoomScale(minimumZoomScale, animated: true)
        } else if maximumZoomScale > minimumZoomScale {
            let zoomeScale = doubleTabZoomScale == nil ? maximumZoomScale / 3.0 : doubleTabZoomScale!
            let zoomRect = zoomRectForScale(scale: zoomeScale, center: recognizer.location(in: recognizer.view))
            zoom(to: zoomRect, animated: true)
        }
    }
    
    func zoomRectForScale(scale : CGFloat, center : CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        if let imageV = self.viewForZooming {
            zoomRect.size.height = imageV.frame.size.height / scale;
            zoomRect.size.width  = imageV.frame.size.width  / scale;
            let newCenter = imageV.convert(center, from: self)
            zoomRect.origin.x = newCenter.x - ((zoomRect.size.width / 2.0));
            zoomRect.origin.y = newCenter.y - ((zoomRect.size.height / 2.0));
        }
        return zoomRect;
    }
}
