//
//  UtilsHelper.swift
//  SereyIO
//
//  Created by Phanha Uy on 3/12/20.
//  Copyright © 2020 Serey IO. All rights reserved.
//

import UIKit
import AVFoundation

class UtilsHelper {
    
    public static func commonCSSStyle(fontSize: CGFloat) -> String {
        if let commonCSS = readFile(withName: "common_css", type: "css") {
            var newCSS = commonCSS
            newCSS = (newCSS as NSString).replacingOccurrences(of: "(font-size-to-replace)", with: "\(fontSize)")
            return String(format: "<style>%@</style>", newCSS)
        }
        
        return ""
    }
    
    public static func trixEditorCSSStyle(with imageWidth: CGFloat? = nil) -> String {
        if let trixCSS = readFile(withName: "trix-editor", type: "css") {
            let widthProperty = imageWidth != nil ? "\(imageWidth!)px" : "100%"
            let newCSS = (trixCSS as NSString).replacingOccurrences(of: "(imageMaxWidth)", with: widthProperty)
            return String(format: "<style>%@</style>", newCSS)
        }
        
        return ""
    }
    
    /// Reads a file from the application's bundle, and returns its contents as a string
    /// Returns nil if there was some error
    public static func readFile(withName name: String, type: String) -> String? {
        if let filePath = Bundle.main.path(forResource: name, ofType: type) {
            do {
                let file = try String(contentsOfFile: filePath, encoding: .utf8) as String // NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding) as String
                return file
            } catch let error {
                print("Error loading \(name).\(type): \(error)")
            }
        }
        return nil
    }
}

// MARK: - File Attributes
extension UtilsHelper {
    
    public static func fileSize(from url: URL) -> Int64 {
        var fileSize: Int64 = 0
        if let attr = try? FileManager.default.attributesOfItem(atPath: url.path) {
            fileSize = Int64(exactly: (attr[.size] as? NSNumber) ?? 0) ?? 0
        }
        return fileSize
    }
    
    public static func fileSize(from image: UIImage) -> Int64 {
        let fileSize: Int64 = Int64((image.jpegData(compressionQuality: 1.0) as NSData?)?.length ?? 0)
        return fileSize
    }
    
    public static func mimeType(from image: UIImage) -> String {
        if let data = (image.jpegData(compressionQuality: 1.0)) {
            return mimeType(for: data)
        }
        
        return DEFAULT_MIME_TYPE
    }
    
    fileprivate static func mimeType(for data: Data) -> String {
        
        var b: UInt8 = 0
        data.copyBytes(to: &b, count: 1)
        
        switch b {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x4D, 0x49:
            return "image/tiff"
        case 0x25:
            return "application/pdf"
        case 0xD0:
            return "application/vnd"
        case 0x46:
            return "text/plain"
        default:
            return DEFAULT_MIME_TYPE
        }
    }
}
