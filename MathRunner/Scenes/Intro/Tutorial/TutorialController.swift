//
//  TutorialController.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit
import SceneKit

class TutorialController: UIViewController {

    @IBOutlet var closeButton: UIImageView!
    @IBOutlet var sceneView: SCNView!

    @IBOutlet var infoLabel: UILabel!
    private var currentInfo: Text = .value1

    @IBOutlet var nextButton: UIImageView!

    @IBOutlet var tutorialHandsImage: UIImageView!

    private lazy var playerNode: SCNNode = player.create()
    private var player = Player()

    private lazy var selfieStickNode: SCNNode = {
        guard
            let node = scene.rootNode.childNode(
                withName: "SelfieStick",
                recursively: true
            )
        else {
            assertionFailure("Not loaded")
            return .init()
        }

        return node
    }()

    private let scene = SCNScene(named: "Art.scnassets/Tutorial/Tutorial.scn")!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupScene()
    }
}

// MARK: - UI

extension TutorialController {
    private func setupScene() {
        setupGame()
        setupPlayer()
        setupActions()
        setupCamera()
    }

    private func setupUI() {
        setupViews()
        setupInfo()
    }

    private func setupViews() {
        infoLabel.textColor = .init(named: "yellow_text")
        view.backgroundColor = .black
        view.isOpaque = true

        sceneView.backgroundColor = .clear
        sceneView.isHidden = false

        setupInfo()
    }

    private func setupInfo() {
        infoLabel.text = currentInfo.rawValue
        infoLabel.font = Fonts.load(
            .supercell,
            size: UIScreen.main.bounds.width * 0.04
        )
    }
}

// MARK: - Game

extension TutorialController {
    private func setupGame() {
        sceneView.scene = scene
    }

    func setupCamera() {
        sceneView.pointOfView = selfieStickNode
    }
}

// MARK: - Player

extension TutorialController {
    private func setupPlayer() {
        sceneView.scene?.rootNode.addChildNode(playerNode)
    }
}

// MARK: - Actions

extension TutorialController {
    private func setupActions() {
        handleSwipe { [weak self] direction in
            self?.updatePlayerPosition(with: direction)
        }

        AccelerometerManager.shared.start()

        AccelerometerManager.shared.handler = { [weak self] direction in
            self?.updatePlayerPosition(with: direction)
        }

        closeButton.addTapGesture { [weak self] in
            guard let self else { return }
            closeButton.simulateTap()
            AccelerometerManager.shared.stop()
            dismiss(animated: true)
        }

        nextButton.addTapGesture { [weak self] in
            guard let self else { return }
            self.nextButton.simulateTap()
            self.setupInfoText(self.currentInfo)
        }
    }

    func updatePlayerPosition(with direction: RunDirection) {
        switch direction {
        case .left:
            playerJumpRight()
        case .right:
            playerJumpLeft()
        case .up:
            playerJump()
        case .down:
            break
        }
    }

    private func playerJump() {
        player.node.animationPlayer(forKey: "idle")?.stop()
        player.node.animationPlayer(forKey: "jump")?.play()

        let jumpHeight: CGFloat = 1.0
        let jumpDuration: TimeInterval = 0.6

        let jumpAction = SCNAction.sequence([
            SCNAction.moveBy(x: 0, y: jumpHeight, z: 0, duration: jumpDuration / 2),
            SCNAction.moveBy(x: 0, y: -jumpHeight, z: 0, duration: jumpDuration / 2)
        ])

        // Run the jump action
        player.node.runAction(jumpAction, forKey: "jumpAction") {
            self.player.node.animationPlayer(forKey: "jump")?.stop()
            self.player.node.animationPlayer(forKey: "idle")?.play()
        }
    }

    private func playerJumpRight() {
        guard player.playerPositionIndex < 2 else { return }
        player.playerPositionIndex += 1

        playerNode.animationPlayer(forKey: "idle")?.stop()
        playerNode.animationPlayer(forKey: "jump")?.play()

        let jumpHeight: CGFloat = 1.0
        let jumpDuration: TimeInterval = 0.6

        let action = SCNAction.sequence([
            SCNAction.moveBy(x: 1.3, y: jumpHeight, z: 0, duration: jumpDuration / 2),
            SCNAction.moveBy(x: 0, y: -jumpHeight, z: 0, duration: jumpDuration / 2)
        ])

        // Run the jump right action
        playerNode.runAction(action, forKey: "jumpRightAction") { [self] in
            playerNode.animationPlayer(forKey: "jump")?.stop()
            playerNode.animationPlayer(forKey: "idle")?.play()
        }
    }

    private func playerJumpLeft() {
        guard player.playerPositionIndex > 0 else { return }
        player.playerPositionIndex -= 1
        playerNode.animationPlayer(forKey: "idle")?.stop()
        playerNode.animationPlayer(forKey: "jump")?.play()

        let jumpHeight: CGFloat = 1.0
        let jumpDuration: TimeInterval = 0.6

        let action = SCNAction.sequence([
            SCNAction.moveBy(x: -1.3, y: jumpHeight, z: 0, duration: jumpDuration / 2),
            SCNAction.moveBy(x: 0, y: -jumpHeight, z: 0, duration: jumpDuration / 2)
        ])

        playerNode.runAction(action, forKey: "jumpLeftAction") { [self] in
            playerNode.animationPlayer(forKey: "jump")?.stop()
            playerNode.animationPlayer(forKey: "idle")?.play()
        }
    }
}

// MARK: - Info

extension TutorialController {
    func setupInfoText(_ text: Text) {
        currentInfo = text.next()
        setupInfo()

        switch currentInfo {
        case .value4:
            tutorialHandsImage.isHidden = false
            animateJumpHands()
        case .value5:
            tutorialHandsImage.isHidden = false
            animateSideWaysHands()
        case .finish:
            Coordinator.shared.startIntro(.challenge)
        default:
            tutorialHandsImage.isHidden = true
        }
    }

    private func animateJumpHands() {
        tutorialHandsImage.layer.removeAllAnimations()

        UIView.animate(
            withDuration: 1,
            delay: .zero,
            options: [.autoreverse, .repeat]
        ) {
            self.tutorialHandsImage.transform = CGAffineTransform(
                translationX: .zero,
                y: 50
            ).rotated(by: .zero)
        }
    }

    private func animateSideWaysHands() {
        tutorialHandsImage.layer.removeAllAnimations()

        UIView.animate(
            withDuration: 2,
            delay: .zero,
            options: [.autoreverse, .repeat]
        ) {
            self.tutorialHandsImage.transform = CGAffineTransform(
                translationX: -50,
                y: .zero
            ).rotated(by: .pi/8)
        }
        UIView.animate(
            withDuration: 2,
            delay: .zero,
            options: [.autoreverse, .repeat]
        ) {
            self.tutorialHandsImage.transform = CGAffineTransform(
                translationX: 50,
                y: .zero
            ).rotated(by: -.pi/8)
        }
    }
}

extension TutorialController {
    enum Text: String {
        case value1 = "Are you ready to help Matthew?"
        case value2 = "Your goal is to run through a Brazilian slum, and by doing so, you will achieve something remarkable."
        case value3 = "Guide Matthew through the slum by solving mathematical operations, unlocking the key to his advancement."
        case value4 = "For example, you can help Matthew to jump, jumping with your iPad."
        case value5 = "Or move sideways with:"
        case finish

        func next() -> Self {
            switch self {
            case .value1:
                return .value2
            case .value2:
                return .value3
            case .value3:
                return .value4
            case .value4:
                return .value5
            case .value5:
                return .finish
            case .finish:
                return .finish
            }
        }
    }
}
