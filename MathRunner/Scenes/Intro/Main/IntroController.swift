//
//  IntroController.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit

class IntroController: UIViewController {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var textView: StarWarsTextView!

    @IBOutlet var closeButton: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFirstAction()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSecondAction()
        setupMusic()
    }

    private func setupFirstAction() {
        setupActions()
        setupUI()
        textView.starWarsDelegate = self
    }

    private func setupSecondAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + (Debug.enabled ? 1 : 5)) { [self] in
            logoGrowing()
            titleLabel.isHidden = true
            logoImage.isHidden = false

            setupThirdAction()
        }
    }

    private func logoGrowing() {
        UIView.animate(withDuration: Debug.enabled ? 1 : 5) {
            self.logoImage.transform = CGAffineTransform(
                scaleX: 0.5,
                y: 0.5
            )
        }
    }

    private func setupThirdAction() {
        DispatchQueue.main.asyncAfter(deadline: .now() + (Debug.enabled ? 1 : 4)) { [self] in
            textView.isHidden = false
            textView.scrollToTop()
            textView.startCrawlingAnimation()
        }
    }

    private func setupUI() {
        titleLabel.font = Fonts.load(.supercell, size: 48)
    }

    private func setupActions() {
        closeButton.addTapGesture { [weak self] in
            guard let self else { return }
            closeButton.simulateTap()
            dismiss(animated: true)
        }
    }

    private func setupMusic() {
        AudioManager.shared.isAmbientVolumeMax = true
    }
}

extension IntroController: StarWarsTextViewDelegate {
    func starWarsTextViewDidStartCrawling(
        _ textView: StarWarsTextView
    ) {}

    func starWarsTextViewDidStopCrawling(
        _ textView: StarWarsTextView,
        finished: Bool
    ) {
        Coordinator.shared.startIntro(.tutorial)
    }
}
