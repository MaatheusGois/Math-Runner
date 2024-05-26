//
//  Calculate.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import Foundation

class Calculator {
    var a: Int = 2
    var b: Int = 2
    var selected: Operation = .addition
    var possibles: [Operation] {
        var possibles = [Operation]()

        if DataStorage.bonus.addition.bonus != .none {
            possibles.append(.addition)
        }

        if DataStorage.bonus.subtraction.bonus != .none {
            possibles.append(.subtraction)
        }

        if DataStorage.bonus.multiplication.bonus != .none {
            possibles.append(.multiplication)
        }

        if DataStorage.bonus.division.bonus != .none {
            possibles.append(.division)
        }

        return possibles
    }

    func make() {
        self.selected = possibles.random()
        self.a = selected.possiblesA.randomElement() ?? .zero
        self.b = selected.possiblesB.randomElement() ?? .zero

        if selected == .division, b > a {
            let c = a
            a = b
            b = c
        }
    }

    func question() -> String {
        return "\(a)\(selected.symbol)\(b)"
    }

    func calculate() -> Int? {
        return selected.perform(a: a, b: b)
    }

    func result() -> String {
        guard let result = calculate() else {
            return "Error"
        }

        return String(result)
    }
}

// MARK: - Operation

extension Calculator {

    enum Operation {
        case addition
        case subtraction
        case multiplication
        case division

        var symbol: String {
            switch self {
            case .addition:
                return "+"
            case .subtraction:
                return "-"
            case .multiplication:
                return "x"
            case .division:
                return "%"
            }
        }

        var possiblesA: [Int] {
            switch self {
            case .addition:
                return [1, 2, 3, 4, 5, 6, 7, 8, 9]
            case .subtraction:
                return [1, 2, 3, 4, 5, 6, 7, 8, 9]
            case .multiplication:
                return [1, 2, 3, 4, 5]
            case .division:
                return [64, 32, 16, 8, 4, 2]
            }
        }

        var possiblesB: [Int] {
            switch self {
            case .addition:
                return [1, 2, 3, 4, 5, 6, 7, 8, 9]
            case .subtraction:
                return [1, 2, 3, 4, 5, 6, 7, 8, 9]
            case .multiplication:
                return [1, 2, 3, 4, 5]
            case .division:
                return [8, 4, 2, 1]
            }
        }

        func perform(a: Int, b: Int) -> Int? {
            switch self {
            case .addition:
                return a + b
            case .subtraction:
                return a - b
            case .multiplication:
                return a * b
            case .division:
                guard b != 0 else {
                    // Division by zero
                    return nil
                }
                return a / b
            }
        }
    }

    enum Bonus {
        case none
        case level1
        case level2
        case level3
    }

    struct Option {
        init(operation: Calculator.Operation, bonus: Calculator.Bonus) {
            self.operation = operation
            self.bonus = bonus
        }

        let operation: Operation
        var bonus: Bonus
    }

    class OptionBonus {
        var addition: Option = .init(operation: .addition, bonus: .none)
        var subtraction: Option = .init(operation: .subtraction, bonus: .none)
        var multiplication: Option = .init(operation: .multiplication, bonus: .none)
        var division: Option = .init(operation: .division, bonus: .none)
    }
}

extension [Calculator.Operation] {
    func random() -> Calculator.Operation {
        guard !isEmpty else { return .addition }
        let randomIndex = Int.random(in: 0..<count)
        return self[randomIndex]
    }
}
