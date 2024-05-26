//
//  LoadingModels.swift
//  MathRunner
//
//  Created by Matheus Gois on 18/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import SceneKit

final class LoadModelsManager {

    static func loadModels() {
        DispatchQueue.main.async {
            Debug.print("Loaded Player: \(player)")
            Debug.print("Loaded Gem: \(gem)")
            Debug.print("Loaded Gem Question: \(gemQuestion)")
            Debug.print("Loaded Book: \(book)")
            Debug.print("Loaded Slum: \(slum)")

            Debug.print("Loaded Obstacle1: \(obstacle1)")
            Debug.print("Loaded Obstacle2: \(obstacle2)")
            Debug.print("Loaded Obstacle2: \(obstacle3)")

            Debug.print("Loaded Particle Collect: \(particleCollect)")
            Debug.print("Loaded Particle Collect Bif: \(particleCollectBig)")

            Debug.print("Loaded Selfie Stick: \(selfieStickNode)")
        }
    }

    // MARK: - Models

    static var player: SCNNode {
        guard
            let scene = SCNScene(named: "Art.scnassets/Character/player_idle.scn")
        else {
            Debug.print("Erro ao carregar o modelo")
            return .init()
        }

        let node = scene.rootNode

        node.scale(1)
        node.eulerAngles = .init(x: .zero, y: .pi, z: .zero)

        return node
    }

    static var gemQuestion: SCNNode = {
        guard
            let scene = SCNScene(
                named: "GemQuestion.usdz",
                inDirectory: "Art.scnassets/Gem",
                options: [.checkConsistency: true]
            ),
            let node = scene.rootNode.childNode(withName: "Geom", recursively: true)
        else {
            Debug.print("Erro ao carregar o modelo Road")
            return .init()
        }
        node.enumerateChildNodes { node, _ in
            node.geometry?.firstMaterial?.lightingModel = .physicallyBased
        }

        node.scale(1)

        return node.flattenedClone()
    }()

    static var gem: SCNNode = {
        guard
            let scene = SCNScene(
                named: "Gem.usdz",
                inDirectory: "Art.scnassets/Gem",
                options: [.checkConsistency: true]
            ),
            let node = scene.rootNode.childNode(withName: "Geom", recursively: true)
        else {
            Debug.print("Erro ao carregar o modelo Road")
            return .init()
        }
        node.enumerateChildNodes { node, _ in
            node.geometry?.firstMaterial?.lightingModel = .physicallyBased
        }

        node.scale(1)

        return node.flattenedClone()
    }()

    static var book: SCNNode = {
        guard
            let scene = SCNScene(
                named: "Book.usdz",
                inDirectory: "Art.scnassets/Book",
                options: [.checkConsistency: true]
            ),
            let node = scene.rootNode.childNode(withName: "Geom", recursively: true)
        else {
            Debug.print("Erro ao carregar o modelo Road")
            return .init()
        }
        node.enumerateChildNodes { node, _ in
            node.geometry?.firstMaterial?.lightingModel = .lambert
        }
        node.scale(0.45)

        return node.flattenedClone()
    }()

    static var slum: SCNNode = {
        guard
            let scene = SCNScene(
                named: "Favela.usdz",
                inDirectory: "Art.scnassets/Scenes",
                options: [.checkConsistency: true]
            ),
            let node = scene.rootNode.childNode(withName: "Geom", recursively: true)
        else {
            Debug.print("Erro ao carregar o modelo Road")
            return .init()
        }
        node.enumerateChildNodes { node, _ in
            node.geometry?.firstMaterial?.lightingModel = .lambert
        }
        node.scale(20)

        return node.flattenedClone()
    }()

    static var selfieStickNode: SCNNode = {
        guard
            var gameScene = SCNScene(
                named: "Art.scnassets/Scenes/SelfieStick.scn"
            ),
            let node = gameScene.rootNode.childNode(
                withName: "SelfieStick",
                recursively: true
            )
        else {
            assertionFailure("Not loaded")
            return .init()
        }

        return node
    }()

}

// MARK: - Obstacles

extension LoadModelsManager {
    static var obstacles: [SCNNode] {
        [
            obstacle1, obstacle2, obstacle3
        ]
    }

    static var obstacle1: SCNNode = { obstacle(1, scale: 13) }()
    static var obstacle2: SCNNode = { obstacle(2) }()
    static var obstacle3: SCNNode = { obstacle(3) }()

    private static func obstacle(_ value: Int, scale: Float = 16) -> SCNNode {
        guard
            let scene = SCNScene(
                named: "Obstacle\(value).usdz",
                inDirectory: "Art.scnassets/Obstacle",
                options: [.checkConsistency: true]
            ),
            let node = scene.rootNode.childNode(withName: "Geom", recursively: true)
        else {
            Debug.print("Erro ao carregar o modelo Road")
            return .init()
        }
        node.enumerateChildNodes { node, _ in
            node.geometry?.firstMaterial?.lightingModel = .lambert
        }
        node.scale(scale)

        return node.flattenedClone()
    }

}

// MARK: - Particles

extension LoadModelsManager {
    static var particleCollect: SCNParticleSystem = {
        particle(.collect)
    }()

    static var particleCollectBig: SCNParticleSystem = {
        particle(.collectBig)
    }()

    static func particle(_ value: SCNScene.Particle) -> SCNParticleSystem {
        SCNParticleSystem(
            named: "\(value.rawValue).scnp",
            inDirectory: "Art.scnassets/Particles/\(value.rawValue)"
        )!
    }
}
