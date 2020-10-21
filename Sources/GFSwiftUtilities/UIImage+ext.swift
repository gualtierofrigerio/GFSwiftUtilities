//
//  File.swift
//  
//
//  Created by Gualtiero Frigerio on 20/10/2020.
//

import UIKit

extension UIImage {
    /// Resize the image
    /// In case of errors, an empty image is returned
    /// - Parameter size: the output image size
    /// - Returns: the resized UIImage
    func resize(size:CGSize) -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(size: size)
            return renderer.image { (context) in
                self.draw(in: CGRect(origin: .zero, size: size))
            }
        }
        else {
            guard let cgImage = self.cgImage else {return UIImage()}
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: cgImage.bitsPerComponent,
                                    bytesPerRow: cgImage.bytesPerRow,
                                    space: cgImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                    bitmapInfo: cgImage.bitmapInfo.rawValue)
            context?.interpolationQuality = .high
            context?.draw(cgImage, in: CGRect(origin: .zero, size: size))
            guard let scaledImage = context?.makeImage() else { return UIImage() }
            return UIImage(cgImage: scaledImage)
        }
    }
    
    /// Returns a resized image with the height or weight having the specified size
    /// The aspect ratio is preserved in case of error an empty image is returned
    /// - Parameter maxSize: The maximum size of the width or height
    /// - Returns: The resized UIImage
    func resize(maxSize:Float) -> UIImage {
        var newSize = CGSize.zero
        let ratio = self.size.width / self.size.height
        if (self.size.width > self.size.height) {
            newSize.width = CGFloat(maxSize)
            newSize.height = CGFloat(maxSize) / ratio
        }
        else {
            newSize.height = CGFloat(maxSize)
            newSize.width = CGFloat(maxSize) * ratio
        }
        return resize(size: newSize)
    }
}
