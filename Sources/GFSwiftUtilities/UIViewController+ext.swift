//
//  UIViewController+ext.swift
//
//
//  Created by Gualtiero Frigerio on 06/10/2020.
//

import UIKit

/// Extention to UIViewController exposing customAdd and customRemoveFromParent
@nonobjc extension UIViewController {
    /// Adds a child to the view controller
    /// and sets an optional frame to the child's view
    /// The child's view is added to the VC view
    /// and didMove(toParent) is called on the child
    /// - Parameters:
    ///   - child: The child view controller to add
    ///   - frame: an optional frame to set to the child view
    func customAdd(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)

        if let frame = frame {
            child.view.frame = frame
        }

        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    /// Removes a view controller from its parent
    /// willMove(toParent) is called, then the view
    /// is removed from its superview and finally
    /// removeFromParent is called
    func customRemoveFromParent() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
