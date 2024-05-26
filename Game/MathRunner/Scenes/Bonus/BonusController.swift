//
//  BonusController.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit

protocol BonusControllerDelegate: AnyObject {
    func didChoiceBonus()
}

class BonusController: UIViewController {

    @IBOutlet weak var subtractionAlertView: UIImageView!
    @IBOutlet weak var subtractionView: UIImageView!

    @IBOutlet weak var multiplicationAlertView: UIImageView!
    @IBOutlet weak var multiplicationView: UIImageView!

    @IBOutlet weak var divisionAlertView: UIImageView!
    @IBOutlet weak var divisionView: UIImageView!

    weak var delegate: BonusControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupAnimations()
        setupActions()
    }

    private func setupAnimations() {
        animateUpDown(view: subtractionAlertView)
        animateUpDown(view: multiplicationAlertView)
        animateUpDown(view: divisionAlertView)
    }

    private func setupActions() {
        DataStorage.bonus.addition.bonus = .none

        subtractionView.addTapGesture { [weak self] in
            guard let self else { return }
            DataStorage.points.value -= 50
            DataStorage.bonus.subtraction.bonus = .level1
            dismiss()
        }

        multiplicationView.addTapGesture { [weak self] in
            guard let self else { return }
            DataStorage.points.value -= 60
            DataStorage.bonus.multiplication.bonus = .level1
            dismiss()
        }

        divisionView.addTapGesture { [weak self] in
            guard let self else { return }
            DataStorage.bonus.division.bonus = .level1
            DataStorage.points.value -= 70
            dismiss()
        }
    }

    private func dismiss() {
        AudioManager.shared.play(.collectBig)
        dismiss(animated: true) { [weak self] in
            self?.delegate?.didChoiceBonus()
        }
    }

    private func animateUpDown(view: UIView) {
        let duration = TimeInterval(0.5)
        let deslocation = Double(20)
        UIView.animate(
            withDuration: duration,
            delay: .zero,
            options: .curveEaseInOut,
            animations: {
                view.frame.origin.y -= deslocation
            },
            completion: { finished in
                if finished {
                    UIView.animate(
                        withDuration: duration,
                        delay: .zero,
                        options: .curveEaseInOut,
                        animations: {
                            view.frame.origin.y += deslocation
                        },
                        completion: { _ in
                            self.animateUpDown(view: view)
                        }
                    )
                }
            }
        )
    }
}
