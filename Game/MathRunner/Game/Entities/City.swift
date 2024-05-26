//
//  City.swift
//  MathRunner
//
//  Created by Matheus Gois on 28/12/23.
//  Copyright © 2023 Matheus Gois. All rights reserved.
//

import SceneKit

struct City {

    var spacing: Float = 220
    var lastZPostion: Float = .zero
    var firstTime = true

    mutating func create() -> [SCNNode] {

        var roadCount = 3
        if firstTime {
            firstTime = false
            roadCount *= 2
        }
        let position = SCNVector3(
            x: 0,
            y: 0,
            z: lastZPostion
        )

        let paths = generatePath(
            initialPosition: position,
            buildingCount: roadCount
        )
        lastZPostion = (paths.last?.z ?? .zero) - spacing
        return createBuildingsAlongPath(path: paths)
    }

    mutating func createAR() -> [SCNNode] {
        spacing = 0.5
        let roadCount = 6

        let position = SCNVector3(
            x: 0,
            y: 0,
            z: lastZPostion
        )

        let paths = generatePath(
            initialPosition: position,
            buildingCount: roadCount
        )
        lastZPostion = (paths.last?.z ?? .zero) - spacing
        return createBuildingsAlongPath(path: paths)
    }

    func generatePath(initialPosition: SCNVector3, buildingCount: Int) -> [SCNVector3] {
        var path: [SCNVector3] = []
        var currentPosition = initialPosition

        for _ in 1...buildingCount {
            path.append(currentPosition)
            currentPosition.z -= spacing
        }

        return path
    }

    func createBuildingsAlongPath(path: [SCNVector3]) -> [SCNNode] {
        var nodes: [SCNNode] = []
        for position in path {
            let node = build(position: position)
            nodes.append(node)
        }
        return nodes
    }

    func build(
        position: SCNVector3
    ) -> SCNNode {
        let component: Component = .floor

        guard
            let node = LoadModelsManager.slum.copy() as? SCNNode
        else { return .init() }

        node.position = position

        node.physicsBody?.categoryBitMask = component.collider
        node.physicsBody?.collisionBitMask = .zero
        node.physicsBody?.restitution = .zero
        node.name = component.rawValue

        return node
    }

    mutating func reset() {
        lastZPostion = -World.initialObstacle
        firstTime = true
    }
}
