//
//  DataStorage.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import Foundation

enum DataStorage {

    static var didUpdatedPoints: (() -> Void)?
    static var points = Points()

    static var bonus = Calculator.OptionBonus()

    static var soundIsActive = true {
        didSet {
            AudioManager.shared.soundIsActive = soundIsActive
        }
    }
    static var hapticIsActive = true

    static var challenge: World.Chalenge = .one

    static var didUpdatedLevelActive: (() -> Void)?

    static var levelActive: [HomeController.Step] = [.intro] {
        didSet {
            didUpdatedLevelActive?()
        }
    }
}
