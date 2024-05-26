//
//  Reward.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/12/23.
//  Copyright © 2023 Matheus Gois. All rights reserved.
//

import SceneKit

struct Reward {
    var spacing: Float = 6
    var lastZPostion: Float = -World.initialObstacle
    var firstTime = true

    mutating func create(quantity: Int) -> [SCNNode] {
        var quantity = quantity
        if firstTime {
            firstTime = false
            quantity *= 2
        }

        let position = SCNVector3(
            x: .zero,
            y: 0.5,
            z: lastZPostion
        )

        let paths = generatePath(
            initialPosition: position,
            count: quantity
        )
        lastZPostion = paths.last?.z ?? .zero
        return createAlongPath(path: paths)
    }

    func generatePath(
        initialPosition: SCNVector3,
        count: Int
    ) -> [SCNVector3] {
        var path: [SCNVector3] = []
        var currentPosition = initialPosition

        for _ in 1...count {
            currentPosition.x = Float(World.positions.randomElement() ?? .zero)
            path.append(currentPosition)
            currentPosition.z -= spacing
        }

        return path
    }

    func createAlongPath(path: [SCNVector3]) -> [SCNNode] {
        var buildingNodes: [SCNNode] = []
        for position in path {
            let buildingNode = createNode(position: position)
            buildingNodes.append(buildingNode)
        }
        return buildingNodes
    }

    func createNode(position: SCNVector3) -> SCNNode {
        let component: Component = .reward

        guard let node = LoadModelsManager.book.copy() as? SCNNode else {
            return .init()
        }

        let rotateAction = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: 5.0)
        let rotateForever = SCNAction.repeatForever(rotateAction)
        node.runAction(rotateForever)

        node.physicsBody = SCNPhysicsBody.kinematic()
        node.physicsBody?.categoryBitMask = component.collider
        node.physicsBody?.collisionBitMask = .zero

        node.name = component.rawValue

        node.position = position

        return node
    }

    mutating func reset() {
        lastZPostion = -World.initialObstacle
        firstTime = true
    }
}
