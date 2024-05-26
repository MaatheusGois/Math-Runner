//
//  Answer.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/12/23.
//  Copyright © 2023 Matheus Gois. All rights reserved.
//

import SceneKit

struct Challenge {

    let height: CGFloat = 2

    func create(
        question: String,
        result: Int,
        zPos: CGFloat
    ) -> [SCNNode] {

        let questionPosition: SCNVector3 = .init(
            .zero,
            9,
            zPos
        )

        let position: SCNVector3 = .init(
            .zero,
            height,
            zPos
        )
        let position1: SCNVector3 = .init(
            World.divisionSize,
            height,
            zPos
        )
        let position2: SCNVector3 = .init(
            -World.divisionSize,
             height,
             zPos
        )

        let positions = [
            position,
            position1,
            position2
        ].shuffled()

        let (a1, a2) = result.generateSimilarNumbers()

        return [
            makeQuestion(
                position: questionPosition,
                label: question
            ),
            makeAnswer(
                position: positions[0],
                label: result.asString
            ),
            makeAnswer(
                position: positions[1],
                label: a1.asString
            ),
            makeAnswer(
                position: positions[2],
                label: a2.asString
            )
        ]
    }

    private func makeQuestion(position: SCNVector3, label: String) -> SCNNode {
        let component: Component = .challenge
        guard let node = LoadModelsManager.gemQuestion.copy() as? SCNNode else { return .init() }

        let labelNode = CustomLabel.createSCNText(text: label, size: 2.3)

        node.addChildNode(labelNode)
        node.name = component.rawValue
        node.position = position

        return node
    }

    private func makeAnswer(position: SCNVector3, label: String) -> SCNNode {

        let component: Component = .challengeAnswer
        guard let node = LoadModelsManager.gem.copy() as? SCNNode else { return .init() }

        let labelNode = CustomLabel.createSCNText(text: label, size: 2.2)

        node.addChildNode(labelNode)

        node.physicsBody = SCNPhysicsBody.kinematic()
        node.physicsBody?.categoryBitMask = component.collider
        node.physicsBody?.friction = .zero
        node.physicsBody?.rollingFriction = .zero
        node.physicsBody?.collisionBitMask = .zero

        node.name = component.rawValue

        node.position = position

        return node
    }
}
