//
//  Bonus.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import Foundation
import UIKit

extension GameController {
    final class Bonus {

        private var constraint: NSLayoutConstraint
        private var label: UILabel
        private weak var controller: UIViewController?

        private var progressHeight = UIScreen.main.bounds.height * 0.4

        private var bonus: CGFloat = 0
        private(set) var numberOfBonus: Int = 1

        init(
            constraint: NSLayoutConstraint,
            label: UILabel,
            controller: UIViewController?
        ) {
            self.constraint = constraint
            self.label = label
        }

        func reset() {
            DispatchQueue.main.async {
                self.bonus = .zero
                self.setupLevel()
                self.resetConstraint()
            }
        }

        func add(with type: BonusType) {
            DispatchQueue.main.async {
                self.bonus += type.value

                self.setupLevel()
                self.animateBar()
            }
        }

        private func setupLevel() {
            let newValue = Int(bonus / 100) + 1

            if newValue > numberOfBonus {
                animateLabel()
            }

            numberOfBonus = newValue
            label.text = "x\(numberOfBonus)"
        }

        private func resetConstraint() {
            constraint.constant = progressHeight
        }

        private func animateBar() {
            let percentage = bonus.truncatingRemainder(dividingBy: 100) / 100
            let constant = progressHeight - progressHeight * percentage

            constraint.constant = constant
        }

        private func animateLabel() {
            let initialSize = label.frame.size
            let targetSize = CGSize(width: initialSize.width * 1.5, height: initialSize.height * 1.5)

            UIView.animate(withDuration: 0.5, animations: {
                self.label.transform = CGAffineTransform(
                    scaleX: targetSize.width / initialSize.width,
                    y: targetSize.height / initialSize.height
                )
            }) { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.label.transform = .identity
                })
            }
        }
    }
}
extension GameController.Bonus {
    enum BonusType {
        case book
        case question

        var value: CGFloat {
            switch self {
            case .book:
                return 10
            case .question:
                return 50
            }
        }
    }
}
