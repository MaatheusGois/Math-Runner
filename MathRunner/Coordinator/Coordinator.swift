//
//  Coordinator.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit

final class Coordinator {

    private init() {}
    static let shared = Coordinator()

    private lazy var gameController: GameController = buildGame()

    private var window: UIWindow = UIWindow(frame: UIScreen.main.bounds)
    private var navigation = UINavigationController()
    private var introNavigation = UINavigationController()

    func start() {
        startLoading()
    }

    private func getController(
        from storyboard: Storybord
    ) -> UIViewController? {
        return UIStoryboard(
            name: storyboard.rawValue,
            bundle: Bundle.main
        ).instantiateInitialViewController()
    }
}

// MARK: - Loading

extension Coordinator {

    func startLoading() {
        if let controller = getController(from: .loader) {
            navigation.viewControllers = [controller]
            self.window.rootViewController = navigation
            self.window.makeKeyAndVisible()
        } else {
            Debug.print("Erro ao carregar a storyboard")
        }
    }
}

// MARK: - Game

extension Coordinator {

    func startGame() {
        navigation.present(gameController, animated: true)
    }

    func prepareGame() {
        gameController.prepare()
    }

    func resetGame() {
        gameController = buildGame()
        gameController.prepare()
    }

    func startResultGame() {
        if let controller = getController(from: .resultGame) {
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .crossDissolve
            navigation.visibleViewController?.present(nav, animated: true)
        } else {
            Debug.print("Erro ao carregar a storyboard")
        }
    }
}

// MARK: - Config

extension Coordinator {

    func startConfig(isInGame: Bool = false, delegate: ConfigControllerDelegate? = nil) {
        if let controller = getController(from: .config) as? ConfigController {
            controller.delegate = delegate
            controller.isInGame = isInGame
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .crossDissolve
            navigation.visibleViewController?.present(nav, animated: true)
        }
    }

    func dismiss() {
        resetGame()
        navigation.dismiss(animated: true)
    }
}

// MARK: - Bonus

extension Coordinator {

    func startBonus(delegate: BonusControllerDelegate? = nil) {
        if let controller = getController(from: .bonus) as? BonusController {
            controller.delegate = delegate
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .crossDissolve
            navigation.visibleViewController?.present(nav, animated: true)
        }
    }
}

// MARK: - Home

extension Coordinator {

    func startHome() {
        if let controller = getController(from: .home) {
            navigation.viewControllers = [controller]
        } else {
            Debug.print("Erro ao carregar a storyboard")
        }
    }

    private func buildGame() -> GameController {
        let controller = getController(from: .game) as! GameController
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve

        return controller
    }
}

// MARK: - Intro

extension Coordinator {

    func startIntro(_ type: Intro) {
        DispatchQueue.main.async {
            switch type {
            case .main:
                self.startIntroMain()
            case .tutorial:
                self.startIntroTutorial()
            case .challenge:
                self.startIntroChalenge()
            case .finish:
                self.startIntroFinish()
            }
        }
    }

    private func startIntroMain() {
        if let controller = getController(from: .intro) {
            introNavigation.modalPresentationStyle = .overFullScreen
            introNavigation.modalTransitionStyle = .crossDissolve
            introNavigation.viewControllers = [controller]
            navigation.present(introNavigation, animated: true)
        } else {
            Debug.print("Erro ao carregar a storyboard")
        }
    }

    private func startIntroTutorial() {
        if let controller = getController(from: .tutorial) {
            introNavigation.pushViewController(controller, animated: true)
        } else {
            Debug.print("Erro ao carregar a storyboard")
        }
    }

    private func startIntroChalenge() {
        if let controller = getController(from: .challenge) {
            introNavigation.pushViewController(controller, animated: true)
        } else {
            Debug.print("Erro ao carregar a storyboard")
        }
    }

    private func startIntroFinish() {
        if let controller = getController(from: .introFinish) {
            introNavigation.pushViewController(controller, animated: true)
        } else {
            Debug.print("Erro ao carregar a storyboard")
        }
    }
}

// MARK: - Finish

extension Coordinator {

    func startFinish() {
        if let controller = getController(from: .finish) as? FinishController {
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .overFullScreen
            nav.modalTransitionStyle = .crossDissolve
            navigation.visibleViewController?.present(nav, animated: true)
        }
    }
}

extension Coordinator {
    enum Storybord: String {
        case loader = "LoaderController"
        case home = "HomeController"
        case config = "ConfigController"
        case game = "GameController"
        case bonus = "BonusController"
        case resultGame = "ResultGameController"
        case finish = "FinishController"

        case intro = "IntroController"
        case tutorial = "TutorialController"
        case challenge = "ChalengeController"
        case introFinish = "IntroFinishController"
    }

    enum Intro {
        case main
        case tutorial
        case challenge
        case finish
    }
}
