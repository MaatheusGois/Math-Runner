//
//  Points.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import Foundation

class Points {
    var value: Int = 0 {
        didSet {
            DataStorage.didUpdatedPoints?()
        }
    }

    var formatted: String {
        .init(("0000" + value.asString).suffix(4))
    }
}
