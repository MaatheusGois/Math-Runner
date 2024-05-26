//
//  UIView+.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit
import SceneKit

extension UIView {
    func addTapGesture(
        tapNumber: Int = 1,
        cancelsTouchesInView: Bool = true,
        _ closure: (() -> Void)?
    ) {
        guard let closure = closure else { return }

        let tap = BindableGestureRecognizer(action: closure)
        tap.numberOfTapsRequired = tapNumber
        tap.cancelsTouchesInView = cancelsTouchesInView

        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    func simulateTap() {
        impactOccurred()
        UIView.animate(
            withDuration: 0.3,
            animations: {
                self.alpha = 0.7
            }
        ) { _ in
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1.0
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    func animateView() {
        let initialSize = frame.size
        let targetSize = CGSize(width: initialSize.width * 1.5, height: initialSize.height * 1.5)

        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(
                scaleX: targetSize.width / initialSize.width,
                y: targetSize.height / initialSize.height
            )
        }) { _ in
            UIView.animate(withDuration: 0.5, animations: {
                self.transform = .identity
            })
        }
    }
}

final class BindableGestureRecognizer: UITapGestureRecognizer {

    private var action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(execute))
    }

    @objc
    private func execute() {
        action()
    }
}

extension NSLayoutConstraint {
    func updateMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        // Deactivate the existing constraint
        isActive = false

        // Create a new constraint with the updated multiplier
        let newConstraint = NSLayoutConstraint(
            item: firstItem!,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant
        )

        // Activate the new constraint
        newConstraint.isActive = true

        return newConstraint
    }
}
