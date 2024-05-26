//
//  World.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/12/23.
//  Copyright © 2023 Matheus Gois. All rights reserved.
//

import Foundation

enum World: Int {
    case toilet = 1
}

extension World {
    static let widthX: Float = 18
    static let divisionSize: CGFloat = 5
    static var positions: [CGFloat] = [-5, 0, 5]
    static let initialObstacle: Float = 40
    static let initialReload: Float = 100

    static let maxChallenge: Int = 6
}

extension World {
    enum Chalenge {
        case one
        case two

        var remove: Int {
            switch self {
            case .one:
                return Debug.enabled ? 5 : 3
            case .two:
                return .zero
            }
        }
    }
}
