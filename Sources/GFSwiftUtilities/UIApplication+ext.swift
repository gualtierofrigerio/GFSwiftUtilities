//
//  UIApplication+ext.swift
//
//  Created by Gualtiero Frigerio on 08/10/2020.
//

import Foundation
import UIKit

/// Extension to UIApplication to add supportedInterfaceOrientations from Info.plist
extension UIApplication {
    /// Reads the array of supported interface orientation from Info.plist in the app's bundle
    /// and returns the corresponding UIInterfaceOrientationMask
    /// - Returns: A UIInterfaceOrientationMask
    static func supportedInterfaceOrientationsFromBundle() -> UIInterfaceOrientationMask {
        var orientations:UIInterfaceOrientationMask = []
        let orientationKey = "UISupportedInterfaceOrientations"
        if let bundleOrientationArray = Bundle.main.object(forInfoDictionaryKey: orientationKey) as? [String] {
            for orientationStr in bundleOrientationArray {
                if orientationStr == "UIInterfaceOrientationPortrait" {
                    orientations.update(with:.portrait)
                }
                else if orientationStr == "UIInterfaceOrientationLandscapeLeft" {
                    orientations.update(with:.landscapeLeft)
                }
                else if orientationStr == "UIInterfaceOrientationLandscapeRight" {
                    orientations.update(with:.landscapeRight)
                }
                else if orientationStr == "UIInterfaceOrientationPortraitUpsideDown" {
                    orientations.update(with:.portraitUpsideDown)
                }
            }
        }
        return orientations
    }
}

