//
//  FinishController.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit
import SceneKit

class IntroFinishController: UIViewController {

    @IBOutlet var sceneView: SCNView!

    @IBOutlet var infoLabel: UILabel!

    @IBOutlet var nextButton: UIImageView!

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

extension IntroFinishController {
    private func setupScene() {
        setupGame()
        setupPlayer()
        setupActions()
        setupCamera()
    }

    private func setupUI() {
        setupViews()
    }

    private func setupViews() {
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

extension IntroFinishController {
    private func setupGame() {
        sceneView.scene = scene
    }

    func setupCamera() {
        selfieStickNode.position = .init(.zero, 2, -10)
        selfieStickNode.eulerAngles = .init(CGFloat.pi, .zero, .pi)
        sceneView.pointOfView = selfieStickNode
    }
}

// MARK: - Player

extension IntroFinishController {
    private func setupPlayer() {
        sceneView.scene?.rootNode.addChildNode(playerNode)
    }
}

// MARK: - Actions

extension IntroFinishController {
    private func setupActions() {
        nextButton.addTapGesture { [weak self] in
            AudioManager.shared.isAmbientVolumeMax = false
            DataStorage.levelActive.append(.firstStage)
            self?.dismiss(animated: true)
        }
    }
}
