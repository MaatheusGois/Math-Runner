//
//  Debug.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/12/23.
//  Copyright © 2023 Matheus Gois. All rights reserved.
//

import Foundation

struct Debug {
    static var enabled = false {
        didSet {
            if enabled {
                DataStorage.levelActive = HomeController.Step.allCases
            }
        }
    }

    static func print(_ items: Any...) {
        guard enabled else { return }
        let result = items.map { "\($0)" }.joined(separator: " ")
        Swift.print("[MathRunner 🚀] →", result)
    }
}
