//
//  LoadingController.swift
//  MathRunner
//
//  Created by Matheus Gois on 18/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit

final class LoaderController: UIViewController {

    @IBOutlet weak var progressLabel: CustomLabel!
    @IBOutlet weak var progressConstraint: NSLayoutConstraint!

    @IBOutlet weak var logoView: UIImageView!

    private var startTime: CFAbsoluteTime!
    private var duration: TimeInterval { Debug.enabled ? 1 : 4 }
    private let totalProgress: CGFloat = 100

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        animateRotation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            LoadModelsManager.loadModels()
            Coordinator.shared.prepareGame()
            AudioManager.shared.play(.musicAmbience)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        startTime = CFAbsoluteTimeGetCurrent()
        let displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateProgressLabel(_:))
        )
        displayLink.add(to: .main, forMode: .default)

        UIView.animate(withDuration: duration, animations: {
            self.progressConstraint.constant = UIScreen.main.bounds.width
            self.view.layoutIfNeeded()
        })
    }

    private func setupUI() {
        progressLabel.font = Fonts.load(
            .supercell,
            size: 24
        )
    }

    @objc
    func updateProgressLabel(_ displayLink: CADisplayLink) {
        let elapsed = CFAbsoluteTimeGetCurrent() - startTime
        let progress = CGFloat(elapsed / duration) * totalProgress

        progressLabel.text = "\(Int(progress))%"

        if elapsed >= duration {
            displayLink.invalidate()
            startNextScreen()
        }
    }

    private func startNextScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            Coordinator.shared.startHome()
        }
    }

    private func animateRotation() {
        UIView.animate(
            withDuration: 1,
            delay: .zero,
            options: .curveLinear,
            animations: { () -> Void in
            self.logoView.transform = self.logoView.transform.rotated(by: .pi / 2)
        }) { finished -> Void in
            if finished {
                self.animateRotation()
            }
        }
    }
}
