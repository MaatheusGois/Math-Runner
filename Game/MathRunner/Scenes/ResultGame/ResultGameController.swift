//
//  ResultGameController.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit
import SceneKit

class ResultGameController: UIViewController {

    @IBOutlet var nextButton: UIImageView!

    lazy var confettiManager = ConfettiManager(superView: view)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        confettiManager.start()
        AudioManager.shared.play(.musicVictory)
    }
}

// MARK: - UI

extension ResultGameController {
    private func setupUI() {
        setupActions()
    }
}

// MARK: - Actions

extension ResultGameController {
    private func setupActions() {
        nextButton.addTapGesture { [weak self] in
            DataStorage.levelActive.append(.firstStage)
            self?.dismiss(animated: true) {
                Coordinator.shared.dismiss()

                if DataStorage.levelActive.contains(.treasure) {
                    DataStorage.levelActive.append(.final)
                } else {
                    DataStorage.levelActive.append(.treasure)
                }

                AudioManager.shared.play(.musicAmbience)
            }
        }
    }
}
