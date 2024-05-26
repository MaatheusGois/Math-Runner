//
//  Component.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/12/23.
//  Copyright © 2023 Matheus Gois. All rights reserved.
//

import Foundation

enum Component: String {
    case player
    case city
    case obstacle
    case floor
    case reload
    case reward
    case challengeAnswer
    case challenge

    var collider: Int {
        switch self {
        case .player:
            return 1
        case .city:
            return 2
        case .obstacle:
            return 3
        case .floor:
            return 4
        case .reload:
            return 5
        case .reward:
            return 6
        case .challengeAnswer:
            return 7
        case .challenge:
            return 8
        }
    }

    /// Restitution force when poop collide with impediment.
    var restitution: CGFloat {
        switch self {
        case .player:
            return 0.5
        default:
            return 1
        }
    }
}
