//
//  FinishController.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit
import SceneKit

final class FinishController: UIViewController {

    @IBOutlet var closeButton: UIImageView!

    @IBOutlet var imageProfile: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!

    @IBOutlet var imageApple: UIImageView!

    private var currentStep: Step = .step1

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupStep()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScene()
        animate()
    }

    private func setupStep() {
        infoLabel.text = currentStep.text
        infoLabel.font = Fonts.load(.supercell, size: currentStep.fontSize)
        switch self.currentStep {
        case .step1:
            break
        case .step2:
            break
        case .step3:
            break
        case .step4:
            titleLabel.isHidden = false
            imageProfile.isHidden = false
        case .step5:
            imageProfile.isHidden = true
            titleLabel.isHidden = true
            infoLabel.isHidden = true

            imageApple.isHidden = false
            logoGrowing()
        case .final:
            dismiss(animated: true)
        }
    }

    private func animate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + currentStep.presentationTime) {
            self.currentStep = self.currentStep.next()
            self.setupStep()
            if self.currentStep != .final {
                self.animate()
            }
        }
    }

    private func logoGrowing() {
        UIView.animate(withDuration: 5) {
            self.imageApple.transform = CGAffineTransform(
                scaleX: 3,
                y: 3
            )
        }
    }
}

// MARK: - UI

extension FinishController {
    private func setupScene() {
        setupActions()
    }

    private func setupView() {
        titleLabel.textColor = .init(named: "yellow_text")
        titleLabel.font = Fonts.load(
            .supercell,
            size: UIScreen.main.bounds.width * 0.05
        )
        infoLabel.textColor = .init(named: "yellow_text")
        infoLabel.font = Fonts.load(
            .supercell,
            size: UIScreen.main.bounds.width * 0.05
        )

        view.backgroundColor = .black
        view.isOpaque = true
    }
}

// MARK: - Actions

extension FinishController {
    private func setupActions() {
        closeButton.addTapGesture { [weak self] in
            guard let self else { return }
            closeButton.simulateTap()
            dismiss(animated: true)
        }
    }
}

// MARK: - Labels

extension FinishController {
    enum Step: String {
        case step1
        case step2
        case step3
        case step4
        case step5
        case final

        var title: String {
            switch self {
            case .step4:
                return "Matheus Gois"
            default:
                return ""
            }
        }

        var text: String {
            switch self {
            case .step1:
                return "Not everyone can become a great artist"
            case .step2:
                return "But a great artist can come from anywhere"
            case .step3:
                return "Think different"
            case .step4:
                return """
                A passionate iOS Developer from Brazil

                Christian, 28 years

                Husband, son, uncle and brother
                """
            default:
                return ""
            }
        }

        var fontSize: CGFloat {
            switch self {
            case .step1, .step2:
                return 60
            case .step3:
                return 100
            case .step4:
                return 40
            default:
                return 0
            }
        }

        var presentationTime: CGFloat {
            if Debug.enabled { return 1 }

            switch self {
            case .step1, .step2, .step3:
                return 5
            case .step4:
                return 10
            case .step5:
                return 6
            case .final:
                return 8
            }
        }

        func next() -> Self {
            switch self {
            case .step1:
                return .step2
            case .step2:
                return .step3
            case .step3:
                return .step4
            case .step4:
                return .step5
            case .step5:
                return .final
            case .final:
                return .final
            }
        }
    }
}
