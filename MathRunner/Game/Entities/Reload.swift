//
//  Reload.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/12/23.
//  Copyright © 2023 Matheus Gois. All rights reserved.
//

import SceneKit

struct Reload {
    func create(zed: Float) -> SCNNode {
        let plane = SCNBox(width: 20, height: 20, length: 0.1, chamferRadius: 20)
        let redMaterial = SCNMaterial()
        redMaterial.diffuse.contents = UIColor.clear
        plane.materials = [redMaterial]

        let node = SCNNode(geometry: plane)
        node.physicsBody = .static()
        node.physicsBody?.categoryBitMask = Component.reload.collider
        node.physicsBody?.collisionBitMask = .zero
        node.position = SCNVector3(0, -0.5, zed + 10)
        node.name = Component.reload.rawValue

        return node
    }
}
