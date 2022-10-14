//
//  CollectionBottomSheetViewController.swift
//  SereyIO
//
//  Created by Mäd on 13/12/2021.
//  Copyright © 2021 Serey IO. All rights reserved.
//

import UIKit
import MaterialComponents

class CollectionBottomSheetViewController: MDCBottomSheetController {
    
    private var lastYOffset: CGFloat = 0
    private var shapeGenerator: MDCRectangleShapeGenerator {
        let shapeGenerator = MDCRectangleShapeGenerator()
        let cornerTreatment = MDCRoundedCornerTreatment(radius: 22)
        shapeGenerator.topLeftCorner = cornerTreatment
        shapeGenerator.topRightCorner = cornerTreatment
        return shapeGenerator
    }
    
    init(contentViewController: UICollectionViewController) {
        super.init(contentViewController: contentViewController)
        
        self.dismissOnDraggingDownSheet = true
        self.trackingScrollView = contentViewController.collectionView
        
        self.setShapeGenerator(shapeGenerator, for: .preferred)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
}

// MARK: - MDCBottomSheetControllerDelegate
extension CollectionBottomSheetViewController: MDCBottomSheetControllerDelegate {
    
    func bottomSheetControllerStateChanged(_ controller: MDCBottomSheetController, state: MDCSheetState) {
    }
    
    func bottomSheetControllerDidChangeYOffset(_ controller: MDCBottomSheetController, yOffset: CGFloat) {
        if lastYOffset != yOffset {
            lastYOffset = yOffset
            if lastYOffset == self.topSafeAreaHeight {
                self.setShapeGenerator(nil, for: .extended)
            } else {
                self.setShapeGenerator(shapeGenerator, for: .extended)
            }
        }
    }
}
