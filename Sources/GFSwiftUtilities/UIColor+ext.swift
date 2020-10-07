//  UIColor+ext.swift
//
//  Created by Gualtiero Frigerio on 06/10/2020.
//

import UIKit

/// An extention to UIColor to create a UIColor from an hex string
/// Two types of strings are supported:
/// - 8 char string with RGB and alpha
/// - 6 char string with RGB only
/// The string can be prefixed with #
extension UIColor {
    /// Create a UIColor from a hex string
    /// The string can have # as a prefix and can be
    /// 6 or 8 chars long (8 chars for the alpha parameter)
    /// - Parameter hexString: The string containing the hex representation of the color
    public convenience init?(hexString: String) {
        let r, g, b, a: CGFloat

        let hexColor = hexString.replacingOccurrences(of: "#", with: "")
        
        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                a = CGFloat(hexNumber & 0x000000ff) / 255
                
                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }
        else if hexColor.count == 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0
            
            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x0000ff) / 255
                a = 1
                
                self.init(red: r, green: g, blue: b, alpha: a)
                return
            }
        }

        return nil
    }
}
