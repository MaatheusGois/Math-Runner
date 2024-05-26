import Foundation
import SceneKit
import UIKit

class Player {

    var playerPositionIndex: Int = 1
    private let speedFactor: CGFloat = 1.5

    private var isJump: Bool = false
    private var jumpState: JumpState = .initial
    private var lastUpdateTime: TimeInterval = .zero
    private var yPos: Float = 0.5

    var node: SCNNode = LoadModelsManager.player

    var isRunning: Bool = false {
        didSet {
            if oldValue != isRunning {
                if isRunning {
                    node.animationPlayer(forKey: "idle")?.stop(withBlendOutDuration: 0.2)
                    node.animationPlayer(forKey: "run")?.play()
                } else {
                    node.animationPlayer(forKey: "run")?.stop(withBlendOutDuration: 0.2)
                    node.animationPlayer(forKey: "idle")?.play()
                }
            }
        }
    }

    var walkSpeed: CGFloat = 1.0 {
        didSet {
            node.animationPlayer(forKey: "run")?.speed = speedFactor / 2
        }
    }

    func create() -> SCNNode {
        loadAnimations()

        let component = Component.player

        node.position = SCNVector3(0, yPos, 0)
        node.physicsBody = SCNPhysicsBody(
            type: .kinematic,
            shape: SCNPhysicsShape(
                geometry: SCNBox(
                    width: 0.8,
                    height: 0.8,
                    length: 0.8,
                    chamferRadius: 0.0
                ),
                options: nil
            )
        )
        node.physicsBody?.restitution = component.restitution

        // Atualize a máscara de colisão para excluir a categoria de recarga (Reload)
        node.physicsBody?.collisionBitMask =
            Component.obstacle.collider |
            Component.city.collider |
            Component.floor.collider

        node.physicsBody?.contactTestBitMask =
            Component.player.collider |
            Component.obstacle.collider |
            Component.city.collider |
            Component.reload.collider |
            Component.reward.collider |
            Component.challengeAnswer.collider

        node.physicsBody?.categoryBitMask = Component.player.collider
        node.name = Component.player.rawValue

        return node
    }

    private func loadAnimations() {
        let runAnimation = loadAnimation(fromSceneNamed: "Art.scnassets/Character/player_run.dae")
        runAnimation.speed = speedFactor / 1.5
        runAnimation.stop()
        runAnimation.animation.animationEvents = [
            SCNAnimationEvent(keyTime: 0.1, block: { _, _, _ in
                AudioManager.shared.playFootStep()
            }),
            SCNAnimationEvent(keyTime: 0.6, block: { _, _, _ in
                AudioManager.shared.playFootStep()
            })
        ]
        node.addAnimationPlayer(runAnimation, forKey: "run")

        let walkAnimation = loadAnimation(fromSceneNamed: "Art.scnassets/Character/player_walk.dae")
        walkAnimation.speed = 1
        walkAnimation.stop()
        node.addAnimationPlayer(walkAnimation, forKey: "walk")

        let jumpAnimation = loadAnimation(fromSceneNamed: "Art.scnassets/Character/player_jump.dae")
        jumpAnimation.speed = 1
        jumpAnimation.stop()
        node.addAnimationPlayer(jumpAnimation, forKey: "jump")

        let dancingAnimation = loadAnimation(fromSceneNamed: "Art.scnassets/Character/player_dancing.dae")
        dancingAnimation.speed = 1
        dancingAnimation.stop()
        node.addAnimationPlayer(dancingAnimation, forKey: "dancing")

        let idleAnimation = loadAnimation(fromSceneNamed: "Art.scnassets/Character/player_idle.dae")
        idleAnimation.speed = 1
        idleAnimation.play()
        node.addAnimationPlayer(idleAnimation, forKey: "idle")
    }

    private func loadAnimation(fromSceneNamed sceneName: String) -> SCNAnimationPlayer {
        let scene = SCNScene(named: sceneName)!
        // find top level animation
        var animationPlayer: SCNAnimationPlayer!
        scene.rootNode.enumerateChildNodes { child, stop in
            if !child.animationKeys.isEmpty {
                animationPlayer = child.animationPlayer(forKey: child.animationKeys[0])
                stop.pointee = true
            }
        }
        return animationPlayer
    }

    // MARK: - Controlling the character

    private var directionAngle: CGFloat = 0.0 {
        didSet {
            node.runAction(
                SCNAction.rotateTo(
                    x: 0.0,
                    y: directionAngle,
                    z: 0.0,
                    duration: 0.1,
                    usesShortestUnitArc: true
                )
            )
        }
    }

    func update(atTime time: TimeInterval, with renderer: SCNSceneRenderer) {
        let deltaTime = time - lastUpdateTime
        let currentFPS = 1 / deltaTime
        lastUpdateTime = time
        node.position.z -= Float(speedFactor) / 200 * Float(currentFPS)

        isJumping()
    }

    func jump() {
        guard !isJump else { return }
        isJump = true
        AudioManager.shared.play(.jump)
        AudioManager.shared.playerStepIsActive = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            AudioManager.shared.playerStepIsActive = true
        }
    }

    func moveLeft() {
        directionAngle = -.pi / 1.5
        movePlayerToPosition(-1)
    }

    func moveRight() {
        directionAngle = .pi / 1.5
        movePlayerToPosition(1)
    }

    private func isJumping() {
        if isJump {
            switch jumpState {
            case .initial:
                node.animationPlayer(forKey: "jump")?.play()
                jumpState = .uping
            case .uping:
                let maxJump: Float = 4
                if node.position.y >= maxJump {
                    jumpState = .flying
                } else {
                    node.position.y += 0.15 * Float(speedFactor)
                }
            case .flying:
                if JumpState.isFlying(step: Float(speedFactor) * 0.7) { return }
                jumpState = .downing
            case .downing:
                node.position.y -= 0.15 * Float(speedFactor)

                if node.position.y <= yPos {
                    jumpState = .initial
                    isJump = false
                    node.animationPlayer(forKey: "jump")?.stop(withBlendOutDuration: 0.1)
                }
            }
        }
    }

    private func movePlayerToPosition(_ newIndex: Int) {
        let index = playerPositionIndex
        guard
            index + newIndex >= 0,
            index + newIndex <= 2
        else {
            directionAngle = .pi
            return
        }
        playerPositionIndex += newIndex
        let newPositionX = World.positions[playerPositionIndex]
        var newPosition = node.presentation.position
        newPosition.x = Float(newPositionX)
        newPosition.z -= Float(speedFactor*2)

        let moveToTargetX = SCNAction.move(to: newPosition, duration: 0.15)
        node.runAction(moveToTargetX) { [weak self] in
            guard let self else { return }
            directionAngle = .pi
        }
    }

    func winner() {
        node.animationPlayer(forKey: "idle")?.stop(withBlendOutDuration: 0.2)
        node.animationPlayer(forKey: "dancing")?.play()
    }
}

extension Player {
    enum JumpState: Int {
        case initial
        case uping
        case flying
        case downing

        static var flyingCount: Float = .zero
        static var flyingBoyCount: Float = 10

        static func isFlying(step: Float) -> Bool {
            flyingCount += step
            if flyingCount > flyingBoyCount {
                flyingCount = .zero
                return false
            } else {
                return true
            }
        }
    }
}
