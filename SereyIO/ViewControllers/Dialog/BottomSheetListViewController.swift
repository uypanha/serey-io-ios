//
//  BottomSheetListViewController.swift
//  SereyIO
//
//  Created by Panha Uy on 5/17/20.
//  Copyright © 2020 Phanha Uy. All rights reserved.
//

import UIKit
import MaterialComponents

class BottomSheetListViewController: MDCBottomSheetController {

    private var lastYOffset: CGFloat = 0
    private var shapeGenerator: MDCRectangleShapeGenerator {
        let shapeGenerator = MDCRectangleShapeGenerator()
        let cornerTreatment = MDCRoundedCornerTreatment(radius: 8)
        shapeGenerator.topLeftCorner = cornerTreatment
        shapeGenerator.topRightCorner = cornerTreatment
        return shapeGenerator
    }
    
    init(contentViewController: UITableViewController) {
        super.init(contentViewController: contentViewController)
        
        self.automaticallyAdjustsScrollViewInsets = true
        self.dismissOnDraggingDownSheet = true
        self.trackingScrollView = contentViewController.tableView
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
extension BottomSheetListViewController: MDCBottomSheetControllerDelegate {
    
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
