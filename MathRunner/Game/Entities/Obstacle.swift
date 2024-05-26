//
//  Obstacle.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/12/23.
//  Copyright © 2023 Matheus Gois. All rights reserved.
//

import SceneKit

struct Obstacle {
    var spacing: Float = 20
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
            y: -1,
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
        let aleatory: [Float] = [1, 2, 3]
        for _ in 1...count {
            currentPosition.x = Float(World.positions.randomElement() ?? .zero)
            path.append(currentPosition)
            currentPosition.z -= spacing * (aleatory.randomElement() ?? .zero)
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
        let component: Component = .obstacle

        guard let node = LoadModelsManager.obstacles.randomElement()?.copy() as? SCNNode else {
            return .init()
        }

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
