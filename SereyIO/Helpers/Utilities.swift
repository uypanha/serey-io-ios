//
//  Utilities.swift
//  Emergency
//
//  Created by Phanha Uy on 11/24/19.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit

class UtilitiesHelper {
    
    // MARK: - Generate QR Code from String
    public static func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                let transform = CGAffineTransform(scaleX: 10, y: 10)
                let scaledQrImage = output.transformed(by: transform)
                return UIImage(ciImage: scaledQrImage)
            }
        }

        return nil
    }
}

class ViewUtiliesHelper {
    
    // MARK: - Create Indicator
    public static func prepareIndicatorAccessory() -> UIImageView {
        return UIImageView(image: R.image.accessoryIcon()?.image(withTintColor: UIColor.lightGray.withAlphaComponent(0.5)))
    }
    
    // MARK: - Default image placeholder
    public static func prepareDefualtPlaceholder() -> UIImage {
        return UIColor.color(.shimmering).withAlphaComponent(0.5).toImage() ?? UIImage()
    }
    
    // MARK: - Default profile image placeholder
    public static func prepareProfilePlaceholder() -> UIImage {
        return R.image.userPlaceholder() ?? UIImage()
    }
}
