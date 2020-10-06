//
//  UIViewController+ext.swift
//
//
//  Created by Gualtiero Frigerio on 06/10/2020.
//

import UIKit

@nonobjc extension UIViewController {
    func customAdd(_ child: UIViewController, frame: CGRect? = nil) {
        child.modalPresentationStyle = .fullScreen
        addChild(child)

        if let frame = frame {
            child.view.frame = frame
        }

        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func customRemoveFromParent() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
