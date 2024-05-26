//
//  SCNNode+.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/12/23.
//  Copyright © 2023 Matheus Gois. All rights reserved.
//

import SceneKit

extension SCNNode {
    var component: Component {
        if let name, let component = Component(rawValue: name) {
            return component
        }
        return .city
    }

    var isRemovable: Bool {
        switch component {
        case .city, .obstacle, .reload, .reward, .challenge, .challengeAnswer:
            return true
        default:
            return false
        }
    }

    func addChildNodes(_ childs: [SCNNode]) {
        childs.forEach { child in
            let isWithinRange = childNodes.contains { existingNode in
                let xDifference = abs(existingNode.position.x - child.position.x)
                let zDifference = abs(existingNode.position.z - child.position.z)
                return xDifference <= 2.0 && zDifference <= 2.0
            }

            if !isWithinRange || child.component == .challengeAnswer || child.component == .challenge {
                addChildNode(child)
            }
        }
    }

    func removeAll(
        in position: CGFloat,
        exclude: [Component] = [
            .city,
            .floor,
            .challengeAnswer,
            .reload,
            .challenge
        ],
        tolerance: Float = 30
    ) {
        let positionZ = Float(position)
        let nodesToRemove = childNodes.filter {
            abs($0.position.z - positionZ) <= tolerance
        }

        nodesToRemove.forEach {
            if !exclude.contains($0.component) {
                $0.removeFromParentNode()
            }
        }
    }

    var text: String? {
        guard
            let textGeometry = childNodes.first(
                where: { $0.geometry is SCNText }
            )?.geometry as? SCNText
        else {
            return nil
        }

        return textGeometry.string as? String
    }

    func scale(_ value: Float) {
        scale.x *= value
        scale.y *= value
        scale.z *= value
    }
}

enum Direction: Int {
    case left
    case right
    case straight
}

extension SCNNode {
    func moveCasually(direction: Direction) {
        let forceX: Float = {
            if presentation.position.x < -5 {
                return 1
            } else if presentation.position.x > 5 {
                return -1
            }
            return (direction == .right) ? 0.8 : -0.8
        }()
        let force = SCNVector3(forceX, 0.0, 0)
        physicsBody?.applyForce(force, asImpulse: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            let counterForce = SCNVector3(-forceX/8, 0.0, 0)
            self.physicsBody?.applyForce(counterForce, asImpulse: true)
        })
    }

    func moveStrong(direction: Direction) {
        let forceX: Float = {
            if presentation.position.x < -5 {
                return 1.5
            } else if presentation.position.x > 5 {
                return -1.5
            }
            return (direction == .right) ? 0.8 : -0.8
        }()
        let force = SCNVector3(forceX, 0.0, 0)
        physicsBody?.applyForce(force, asImpulse: true)
    }

    func moveSpecific(specificX: Float) {
        let force = SCNVector3(specificX, 0.0, 0.0)
        physicsBody?.applyForce(force, asImpulse: true)
    }

    func moveForever() {
        moveForward()
    }

    private func moveForward() {
        let currentPosition = self.position
        let action = SCNAction.move(
            to: SCNVector3(currentPosition.x, currentPosition.y, -6),
            duration: 1
        )
        self.runAction(action)
    }
}
