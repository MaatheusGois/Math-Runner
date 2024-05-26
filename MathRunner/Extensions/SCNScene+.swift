//
//  SCNScene+.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import SceneKit

// MARK: - Scene

extension SCNScene {
    func emit(
        _ sparkleSystem: SCNParticleSystem,
        at position: SCNVector3,
        color: UIColor
    ) {

        sparkleSystem.particleColor = color

        // Create a new node to attach the particle system
        let sparkleNode = SCNNode()
        sparkleNode.position = position
        sparkleNode.addParticleSystem(sparkleSystem)

        // Add the sparkle node to the scene
        rootNode.addChildNode(sparkleNode)

        let duration = TimeInterval(0.05)

        let moveAction = SCNAction.move(
            by: .init(x: .zero, y: .zero, z: -8),
            duration: duration
        )

        sparkleNode.runAction(moveAction)
        let removeAction = SCNAction.sequence([
            SCNAction.wait(duration: duration),
            SCNAction.removeFromParentNode()
        ])

        sparkleNode.runAction(removeAction)
    }

    enum Particle: String {
        case collect = "Collect"
        case collectBig = "CollectBig"
        case stars = "Stars"
    }
}
