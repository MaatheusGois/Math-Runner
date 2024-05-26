//
//  ConfigController.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit

protocol ConfigControllerDelegate: AnyObject {
    func didCloseConfig()
}

class ConfigController: UIViewController {

    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var settingsLabel: CustomLabel!

    @IBOutlet weak var settingsSoundTitle: CustomLabel!
    @IBOutlet weak var settingsSoundSwitch: ToggleSwitchView!
    @IBOutlet weak var settingsHapticTitle: CustomLabel!
    @IBOutlet weak var settingsHapticSwitch: ToggleSwitchView!

    @IBOutlet weak var buttonsContainer: UIStackView!
    @IBOutlet weak var continueButton: UIImageView!
    @IBOutlet weak var exitButton: UIImageView!
    @IBOutlet weak var constraint: NSLayoutConstraint!

    weak var delegate: ConfigControllerDelegate?
    var isInGame: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSettings()
        setupActions()
        setupUI()

        if isInGame {
            setupForGame()
        }
    }

    func setupForGame() {
        settingsLabel.text = "Pause"
        constraint = constraint.updateMultiplier(1.22)
        buttonsContainer.isHidden = false
    }

    private func setupSettings() {
        settingsSoundSwitch.isActived = DataStorage.soundIsActive
        settingsHapticSwitch.isActived = DataStorage.hapticIsActive
    }

    private func setupActions() {
        exitButton.addTapGesture { [weak self] in
            self?.exitGame()
        }

        continueButton.addTapGesture { [weak self] in
            self?.dismiss()
        }

        closeButton.addTapGesture { [weak self] in
            self?.dismiss()
        }

        settingsSoundSwitch.action = { value in
            Debug.print("Sound: \(value)")
            DataStorage.soundIsActive = value
        }

        settingsHapticSwitch.action = { value in
            Debug.print("Haptic: \(value)")
            DataStorage.hapticIsActive = value
        }
    }

    private func setupUI() {
        setupLabels()
    }

    private func setupLabels() {
        settingsLabel.strokeWidth = .zero
        settingsLabel.font = Fonts.load(.supercell, size: 38)
        settingsLabel.alpha = 0.3

        settingsSoundTitle.font = Fonts.load(.supercell, size: 20)
        settingsHapticTitle.font = Fonts.load(.supercell, size: 20)

        settingsSoundTitle.textAlignment = .left
        settingsHapticTitle.textAlignment = .left
    }

    private func dismiss() {
        delegate?.didCloseConfig()
        closeButton.simulateTap()
        dismiss(animated: true, completion: nil)
    }

    private func exitGame() {
        closeButton.simulateTap()
        dismiss(animated: false) {
            Coordinator.shared.dismiss()
        }
    }
}
