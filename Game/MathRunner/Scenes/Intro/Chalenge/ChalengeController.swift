//
//  ChalengeController.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit
import SceneKit

class ChalengeController: UIViewController {

    @IBOutlet var closeButton: UIImageView!
    @IBOutlet var sceneView: SCNView!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var nextButton: UIImageView!

    private lazy var playerNode: SCNNode = player.create()
    private var player: Player = {
        let player = Player()
        return player
    }()

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

    private lazy var challengeAnswer: SCNNode = {
        guard
            let node = scene.rootNode.childNode(
                withName: "challengeAnswer2",
                recursively: true
            )
        else {
            assertionFailure("Not loaded")
            return .init()
        }

        return node
    }()

    private let scene = SCNScene(named: "Art.scnassets/Tutorial/Challenge.scn")!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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

extension ChalengeController {
    private func setupScene() {
        setupGame()
        setupCamera()
        setupChallenge()
        setupActions()
    }

    private func setupView() {
        infoLabel.textColor = .init(named: "yellow_text")
        infoLabel.font = Fonts.load(
            .supercell,
            size: UIScreen.main.bounds.width * 0.04
        )

        view.backgroundColor = .black
        view.isOpaque = true

        sceneView.backgroundColor = .clear
        sceneView.isHidden = false
    }
}

// MARK: - Game

extension ChalengeController {
    private func setupGame() {
        sceneView.scene = scene
    }

    func setupCamera() {
        sceneView.pointOfView = selfieStickNode
    }
}

// MARK: - Challenge

extension ChalengeController {
    private func setupChallenge() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.animateCorrect()
        }
    }

    private func animateCorrect() {
        let duration: TimeInterval = 1
        let growAction = SCNAction.scale(
            by: 1.3,
            duration: duration
        )
        let shrinkAction = SCNAction.scale(
            by: 1.0 / 1.3,
            duration: duration
        )
        let sequence = SCNAction.sequence([growAction, shrinkAction])
        let repeatForeverAction = SCNAction.repeatForever(sequence)
        challengeAnswer.runAction(repeatForeverAction, forKey: "growShrinkAction")
    }
}

// MARK: - Actions

extension ChalengeController {
    private func setupActions() {
        closeButton.addTapGesture { [weak self] in
            guard let self else { return }
            closeButton.simulateTap()
            dismiss(animated: true)
        }

        nextButton.addTapGesture {
            Coordinator.shared.startIntro(.finish)
        }
    }
}
