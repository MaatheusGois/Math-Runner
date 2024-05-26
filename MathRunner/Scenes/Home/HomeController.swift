//
//  HomeViewControler.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit

final class HomeController: UIViewController {

    @IBOutlet weak var configButton: UIImageView!

    @IBOutlet weak var introStepView: StepView!
    @IBOutlet weak var tutorialStepView: StepView!
    @IBOutlet weak var treasureStepView: StepView!
    @IBOutlet weak var secondStageStepView: StepView!
    @IBOutlet weak var finalStepView: StepView!

    @IBOutlet weak var pointsLabel: UpdateLabel!

    lazy var confettiManager = ConfettiManager(superView: view)

    private var hasEnable: [HomeController.Step] {
        DataStorage.levelActive
    }

    private var hasSelectedBonus = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupActiveViews()
        setupPoints()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    private func setupUI() {
        pointsLabel.strokeWidth = -3
        pointsLabel.font = Fonts.load(.supercell, size: 22)
    }

    private func setupPoints() {
        pointsLabel.animate(to: DataStorage.points.value)
    }

    private func setupActiveViews() {
        hasEnable.forEach { step in
            view(for: step).active()
        }
    }

    private func setupActions() {
        setupConfigAction()
        setupStepsActions()
    }

    private func setupConfigAction() {
        configButton.addTapGesture { [weak self] in
            self?.configButton.simulateTap()
            Coordinator.shared.startConfig()
        }
    }

    private func setupStepsActions() {
        introStepView.addTapGesture { [weak self] in
            self?.startIntro()
        }

        tutorialStepView.addTapGesture { [weak self] in
            self?.openFirstStage()
        }

        treasureStepView.addTapGesture { [weak self] in
            self?.getTreasure()
        }

        secondStageStepView.addTapGesture { [weak self] in
            self?.openSecondStage()
        }

        finalStepView.addTapGesture { [weak self] in
            self?.openFinal()
        }

        DataStorage.didUpdatedLevelActive = { [weak self] in
            DispatchQueue.main.async {
                self?.setupActiveViews()
            }
        }

        DataStorage.didUpdatedPoints = { [weak self] in
            DispatchQueue.main.async {
                self?.setupPoints()
            }
        }
    }

    private func view(for step: Step) -> StepView {
        switch step {
        case .intro:
            return introStepView
        case .firstStage:
            return tutorialStepView
        case .treasure:
            return treasureStepView
        case .secondStage:
            return secondStageStepView
        case .final:
            return finalStepView
        }
    }
}

// MARK: - Intro

extension HomeController {
    func startIntro() {
        if hasEnable.contains(.intro) {
            introStepView.simulateTap()
            Coordinator.shared.startIntro(.main)
        }
    }
}

// MARK: - First Stage

extension HomeController {
    func openFirstStage() {
        guard hasEnable.contains(.firstStage) else { return }

        tutorialStepView.simulateTap()
        Coordinator.shared.startGame()
    }
}

// MARK: - Treasure

extension HomeController {
    func getTreasure() {
        guard
            hasEnable.contains(.treasure),
            !treasureStepView.treasureIsOpen()
        else { return }

        treasureStepView.simulateTap()
        treasureStepView.openTreasure()

        DataStorage.points.value += 100
        DataStorage.levelActive.append(.secondStage)
        DataStorage.challenge = .two

        setupPoints()

        confettiManager.start()
    }
}

// MARK: - Bonus

extension HomeController: BonusControllerDelegate {
    func didChoiceBonus() {
        startGame()
    }
}

// MARK: - Second Stage

extension HomeController {

    func openSecondStage() {
        guard hasEnable.contains(.secondStage) else { return }

        secondStageStepView.simulateTap()

        if hasSelectedBonus {
            startGame()
        } else {
            hasSelectedBonus = true
            Coordinator.shared.startBonus(delegate: self)
        }
    }

    func startGame() {
        Coordinator.shared.startGame()
    }
}

// MARK: - Final

extension HomeController {
    func openFinal() {
        guard hasEnable.contains(.final) else { return }

        finalStepView.simulateTap()
        Coordinator.shared.startFinish()
    }
}

extension HomeController {
    enum Step: Int, CaseIterable {
        case intro
        case firstStage
        case treasure
        case secondStage
        case final
    }
}
