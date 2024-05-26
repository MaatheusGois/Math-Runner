//
//  StepView.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit

final class StepView: UIImageView {

    @IBInspectable var optionRawValue: Int {
        get {
            return _option.rawValue
        }
        set {
            if let option = Option(rawValue: newValue) {
                _option = option
                setupCommon()
            }
        }
    }

    private var _option: Option = .none
    private var currentImageName: String {
        "\(_option.imageValue)_\(state.rawValue)"
    }

    private var state: State = .off {
        didSet {
            setupCommon()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupCommon()
    }

    func active() {
        guard state != .open else { return }
        state = .on
    }

    func treasureIsOpen() -> Bool {
        _option == .treasure && state == .open
    }

    func openTreasure() {
        guard _option == .treasure, state != .open else { return }
        state = .open
        AudioManager.shared.play(.musicVictory)
    }

    private func setupCommon() {
        UIView.transition(
            with: self,
            duration: 0.5,
            options: .transitionCrossDissolve
        ) {
            self.image = .init(named: self.currentImageName)
        }
    }
}

extension StepView {
    enum Option: Int {
        case none
        case lecture
        case treasure
        case step

        var imageValue: String {
            switch self {
            case .none:
                return ""
            case .lecture:
                return "lecture"
            case .treasure:
                return "treasure"
            case .step:
                return "step"
            }
        }
    }

    enum State: String {
        case off
        case on
        case open
    }
}
