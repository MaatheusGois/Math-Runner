//
//  SwipeGestureManager.swift
//  MathRunner
//
//  Created by Matheus Gois on 25/12/23.
//  Copyright © 2023 Matheus Gois. All rights reserved.
//

import UIKit

extension UIViewController {
    func handleSwipe(completion: @escaping (RunDirection) -> Void) {

        let directions: [RunDirection] = [.left, .right, .up, .down]

        for direction in directions {
            let swipeGestureRecognizer = UISwipeGestureRecognizer(
                target: self,
                action: #selector(handleSwipeGestureRecognizer(_:))
            )
            swipeGestureRecognizer.direction = swipeDirectionToUIGestureRecognizerDirection(direction)
            view.addGestureRecognizer(swipeGestureRecognizer)
        }

        view.isUserInteractionEnabled = true
        let completionClosure: (RunDirection) -> Void = { direction in
            completion(direction)
        }
        objc_setAssociatedObject(
            self,
            &AssociatedKeys.swipeCompletion,
            completionClosure,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
    }

    @objc private func handleSwipeGestureRecognizer(
        _ gestureRecognizer: UISwipeGestureRecognizer
    ) {
        if
            let completionClosure = objc_getAssociatedObject(self, &AssociatedKeys.swipeCompletion)
                as? (RunDirection) -> Void {
            let direction: RunDirection
            switch gestureRecognizer.direction {
            case .left:
                direction = .left
            case .right:
                direction = .right
            case .up:
                direction = .up
            case .down:
                direction = .down
            default:
                direction = .left
            }
            completionClosure(direction)
        }
    }

    private func swipeDirectionToUIGestureRecognizerDirection(_ direction: RunDirection) -> UISwipeGestureRecognizer.Direction {
        switch direction {
        case .left: return .left
        case .right: return .right
        case .up: return .up
        case .down: return .down
        }
    }
}

// Estrutura auxiliar para definir chaves associadas
private struct AssociatedKeys {
    static var swipeCompletion = "swipeCompletion"
}
