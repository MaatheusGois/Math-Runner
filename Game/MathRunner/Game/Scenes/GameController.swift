//
//  GameController.swift
//  TheRace
//
//  Created by Matheus Gois on 24/12/23
//  Copyright © 2018 Matheus Gois. All rights reserved.
//

import UIKit
import SceneKit

final class GameController: UIViewController {

    // MARK: - Points

    @IBOutlet weak var pointsLabel: UpdateLabel!

    private var gamePoints = Points()

    // MARK: - Config

    @IBOutlet weak var configButton: UIImageView!
    private var configIsOpen: Bool = false

    // MARK: - Loading

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingLabel: UILabel!

    // MARK: - Bonus

    @IBOutlet weak var bonusConstraint: NSLayoutConstraint!
    @IBOutlet weak var bonusLabel: CustomLabel!

    private lazy var bonus = Bonus(
        constraint: bonusConstraint,
        label: bonusLabel,
        controller: self
    )

    @IBOutlet weak var challengeStack: UIStackView!

    // MARK: - Calculator

    private var calculator = Calculator()

    private let challenge = Challenge()
    private var obstacle = Obstacle()
    private var reload = Reload()
    private var reward = Reward()
    private var city = City()

    // MARK: - Scene

    private var sceneView: SCNView { view as! SCNView }
    private let scene = SCNScene(named: "Art.scnassets/Scenes/MainScene.scn")!

    private let player = Player()
    private lazy var playerNode: SCNNode = player.create()
    private lazy var selfieStickNode: SCNNode = LoadModelsManager.selfieStickNode

    private var length: Float = .zero
    private let stageLenght: Float = -100

    private var hasStarted = false
    private var started = false {
        didSet {
            started ? AccelerometerManager.shared.start() : AccelerometerManager.shared.stop()
            shouldMoveCamera = started
            player.isRunning = started
        }
    }

    private var questionPos: CGFloat = -200
    private let questionPosLenght: CGFloat = -300

    private var shouldMoveCamera = false
    private var isLoading = false
    private var contactHasBeenProcessed = false

    // MARK: - Lifecycle

    override func loadView() {
        super.loadView()
        view = sceneView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateCamera()
        addChallenge()
        setupChallenge()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func prepare() {
        setupScene()
        setupFloor()
        setupControll()
        setupCharacter()

        sceneView.prepare([scene]) { [weak self] _ in
            self?.setupCamera()
        }

        loadData()
    }

    func setupCharacter() {
        playerNode.position = .init(x: .zero, y: .zero, z: .zero)
        scene.rootNode.addChildNode(playerNode)
    }

    func setupScene() {
        sceneView.isPlaying = false
        sceneView.delegate = self
        sceneView.allowsCameraControl = false
        sceneView.scene = scene

        scene.physicsWorld.contactDelegate = self
        scene.physicsWorld.gravity = .init(.zero, -2, .zero)
    }

    func setupCamera() {
        scene.rootNode.addChildNode(selfieStickNode)
        selfieStickNode.position = playerNode.presentation.position

        let camera = SCNCamera()
        selfieStickNode.camera = camera
        selfieStickNode.camera?.zNear = 0.1
        selfieStickNode.camera?.zFar = 400
        selfieStickNode.camera?.wantsHDR = true
        selfieStickNode.camera?.fieldOfView = 90
        selfieStickNode.eulerAngles = SCNVector3(
            x: -Float.pi / 12,
            y: .zero,
            z: .zero
        )
        sceneView.pointOfView = selfieStickNode
        updateCamera()
    }

    func setupFloor() {
        scene.rootNode.addChildNodes(
            city.create()
        )
    }

    var location = CGPoint()

    var isTouching = false

    func setupControll() {
        handleSwipe { [weak self] direction in
            self?.updatePlayerPosition(with: direction)
        }

        Self.handleKeyboard = { [weak self] direction in
            self?.updatePlayerPosition(with: direction)
        }

        AccelerometerManager.shared.handler = { [weak self] direction in
            self?.updatePlayerPosition(with: direction)
        }
    }

    func updatePlayerPosition(with direction: RunDirection) {
        guard started else { return }
        switch direction {
        case .left:
            player.moveLeft()
        case .right:
            player.moveRight()
        case .up:
            player.jump()
        case .down:
//            player.attack()
            break
        }
    }
}

extension GameController: SCNSceneRendererDelegate {

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if shouldMoveCamera {
            updateCamera()
        }
        if started {
            player.update(atTime: time, with: renderer)
        }
    }

    private func updateCamera() {
        let yTot: Float = 6
        let zTot: Float = 6

        let ball = playerNode.presentation
        let ballPosition = ball.position
        let targetPosition = SCNVector3(
            x: ballPosition.x/2,
            y: yTot,
            z: ballPosition.z + zTot
        )
        var cameraPosition = selfieStickNode.position
        let camDamping: Float = 0.3
        let xComponent = cameraPosition.x * (1 - camDamping) + targetPosition.x * camDamping
        let yComponent = cameraPosition.y * (1 - camDamping) + targetPosition.y * camDamping
        let zComponent = cameraPosition.z * (1 - camDamping) + targetPosition.z * camDamping
        cameraPosition = SCNVector3(x: xComponent, y: yComponent, z: zComponent)
        selfieStickNode.position = cameraPosition
    }
}

extension GameController: SCNPhysicsContactDelegate {
    private func loadData() {
        guard !isLoading else { return }
        isLoading = true

        removeObjects()
        addObjects()

        Debug.print("Nodes:", scene.rootNode.childNodes.count)
        Debug.print("Road Size:", length)
    }

    private func addObjects() {
        DispatchQueue.main.async { [self] in
            length += stageLenght

            addRewards()
            addObstacles()
            addReload()
            setupFloor()

            if questionPos <= CGFloat(length) {
                scene.rootNode.removeAll(in: questionPos)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
        }
    }

    private func removeObjects() {
        let playerZPosition = playerNode.presentation.position.z + 10
        func hasPassed(_ node: SCNNode) -> Bool {
            node.isRemovable && node.presentation.position.z > playerZPosition
        }
        scene.rootNode.childNodes.filter(hasPassed(_:)).forEach {
            $0.removeFromParentNode()
        }
    }

    private func addReload() {
        scene.rootNode.addChildNode(
            reload.create(zed: length)
        )
    }

    private func addRewards() {
        scene.rootNode.addChildNodes(
            reward.create(quantity: 20)
        )
    }

    private func addObstacles() {
        scene.rootNode.addChildNodes(
            obstacle.create(quantity: 10)
        )
    }

    private func addChallenge() {
        calculator.make()
        scene.rootNode.removeAll(in: questionPos)
        scene.rootNode.addChildNodes(
            challenge.create(
                question: calculator.question(),
                result: calculator.calculate() ?? .zero,
                zPos: questionPos
            )
        )
    }

    func physicsWorld(
        _ world: SCNPhysicsWorld,
        didBegin contact: SCNPhysicsContact
    ) {
        if contact.nodeB.component == .reload {
            loadData()
        }

        guard !contactHasBeenProcessed else {
            return
        }
        contactHasBeenProcessed = true

        if contact.nodeB.component == .reward {
            getReward(contact.nodeB)
        }

        if contact.nodeB.component == .challengeAnswer {
            getChallenge(contact.nodeB)
        }

        if contact.nodeB.component == .obstacle {
            getObstable(contact.nodeB)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.contactHasBeenProcessed = false
        }
    }

    private func getReward(_ node: SCNNode) {
        addPoints()
        node.removeFromParentNode()

        scene.emit(
            LoadModelsManager.particleCollect,
            at: node.position,
            color: .white
        )

        bonus.add(with: .book)
        AudioManager.shared.play(.collect)
    }

    private func getObstable(_ node: SCNNode) {
        node.removeFromParentNode()

        scene.emit(
            LoadModelsManager.particleCollect,
            at: node.position,
            color: .red
        )

        bonus.reset()
        AudioManager.shared.play(.hit)
    }
}

// MARK: - UI

extension GameController {

    private func setupUI() {
        setupActions()
        setupPoints()
        setupBonus()
    }

    private func setupActions() {
        configButton.addTapGesture { [weak self] in
            guard let self else { return }
            configIsOpen = true
            configButton.simulateTap()
            started = false
            Coordinator.shared.startConfig(isInGame: true, delegate: self)
        }

        loadingView.addTapGesture { [weak self] in
            guard let self else { return }

            setupLoadingCount()
            countLoading()
        }
    }
}

// MARK: - Config

extension GameController: ConfigControllerDelegate {
    func didCloseConfig() {
        configIsOpen = false
        countLoading()
    }
}

// MARK: - Loading

extension GameController {
    private func setupLoadingCount() {
        loadingView.isUserInteractionEnabled = false
        loadingView.backgroundColor = .clear
        loadingLabel.font = Fonts.load(.supercell, size: 200)
    }

    private func countLoading(
        with seconds: Int = 3,
        completion: (() -> Void)? = nil
    ) {
        guard !configIsOpen else {
            loadingLabel.isHidden = true
            return
        }
        AudioManager.shared.isAmbientActive = false
        loadingLabel.isHidden = false

        if seconds > .zero {
            AudioManager.shared.play(.collect)
            loadingLabel.text = "\(seconds)"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.countLoading(
                    with: seconds - 1,
                    completion: completion
                )
            }
        } else {
            AudioManager.shared.play(.collectBig)
            loadingLabel.text = "Go!!!"
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                AudioManager.shared.isAmbientActive = true
                self.started = true
                self.loadingLabel.isHidden = true
                completion?()
            }
        }
    }
}

// MARK: - Points

extension GameController {
    private func setupPoints() {
        gamePoints.value = .zero
        pointsLabel.text = gamePoints.formatted

        pointsLabel.strokeWidth = .zero
        pointsLabel.font = Fonts.load(.supercell, size: 22)
        pointsLabel.textColor = .init(named: "bonus_text")
    }

    private func addPoints() {
        gamePoints.value += 1 * bonus.numberOfBonus
        DispatchQueue.main.async { [self] in
            pointsLabel.animate(to: gamePoints.value)
        }
    }
}

// MARK: - Bonus

extension GameController {
    private func setupBonus() {
        bonus.reset()
        bonusLabel.strokeWidth = .zero
        bonusLabel.font = Fonts.load(.supercell, size: 14)
        bonusLabel.textColor = .init(named: "bonus_text")
    }
}

// MARK: - Challenge

extension GameController {
    private func getChallenge(_ node: SCNNode) {
        let challenge = node.text ?? ""
        node.removeFromParentNode()

        // If get correct answer
        if calculator.result() == challenge {
            scene.emit(
                LoadModelsManager.particleCollectBig,
                at: node.position,
                color: .white
            )

            bonus.add(with: .question)
            DispatchQueue.main.async {
                self.verifyFinish()
                AudioManager.shared.play(.collectBig)
            }
        }

        questionPos += questionPosLenght
        addChallenge()
    }

    private func setupChallenge() {
        challengeStack.subviews.prefix(
            DataStorage.challenge.remove
        ).forEach { view in
            view.removeFromSuperview()
        }
    }

    private func verifyFinish() {
        let isLast = challengeStack.subviews.filter({ $0.tag == .zero }).count == 1
        let view = challengeStack.subviews.first(where: { $0.tag == .zero })
        view?.tag = 1

        if let view = view as? UIImageView {
            UIView.transition(
                with: view,
                duration: 0.5,
                options: .transitionCrossDissolve
            ) {
                view.image = .init(named: "result_on")
            }
            if !isLast {
                view.animateView()
            }
        }

        if isLast {
            for view in challengeStack.subviews {
                view.animateView()
            }

            DataStorage.points.value += gamePoints.value

            started = false

            playerNode.eulerAngles = .zero
            player.winner()

            setupCamera()
            selfieStickNode.position.z += 1

            if player.playerPositionIndex == 0 {
                selfieStickNode.position.x -= 1
            }

            if player.playerPositionIndex == 2 {
                selfieStickNode.position.x += 1
            }

            Coordinator.shared.startResultGame()
        }
    }
}
