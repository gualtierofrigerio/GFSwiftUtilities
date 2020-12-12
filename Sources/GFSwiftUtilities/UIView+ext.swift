//
//  UIView+ext.swift
//  
//  Created by Gualtiero Frigerio on 12/12/2020.
//

import UIKit

extension UIView {
    /// Tries to take a screenshot of the view and draw it to a UIImage
    /// - Returns: The optional UIImage
    func saveAsUImage() -> UIImage? {
        UIGraphicsBeginImageContext(bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}
