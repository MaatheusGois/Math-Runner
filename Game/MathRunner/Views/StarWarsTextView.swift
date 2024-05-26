//
//  IntroStarWars.swift
//  MathRunner
//
//  Created by Matheus Gois on 21/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit

protocol StarWarsTextViewDelegate: NSObjectProtocol {
    func starWarsTextViewDidStartCrawling(
        _ textView: StarWarsTextView
    )
    func starWarsTextViewDidStopCrawling(
        _ textView: StarWarsTextView,
        finished: Bool
    )
}

final class StarWarsTextView: UITextView {

    weak var starWarsDelegate: StarWarsTextViewDelegate?

    private var inclinationRatio: CGFloat = 3
    private var xAngle: CGFloat = 20
    private var crawlingSpeed: CGFloat = Debug.enabled ? 80 : 15
    private var crawlingStepInterval: TimeInterval = 0.2

    var isCrawling: Bool { scrollingTimer != nil }

    private weak var scrollingTimer: Timer?

    // MARK: - Instance API

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    func scrollToTop(animated: Bool = false) {
        let initialPoint = CGPoint(
            x: .zero,
            y: -contentInset.top/1.7
        )
        setContentOffset(initialPoint, animated: animated)
    }

    func startCrawlingAnimation() {
        guard !isCrawling else { return }
        starWarsDelegate?.starWarsTextViewDidStartCrawling(self)

        scrollingTimer = Timer.scheduledTimer(
            withTimeInterval: crawlingStepInterval,
            repeats: true
        ) { [weak self] timer in
            guard let self else { return }

            var scrollPoint = contentOffset

            if scrollPoint.y >= -100 {
                timer.invalidate()
                starWarsDelegate?.starWarsTextViewDidStopCrawling(
                    self,
                    finished: true
                )
            } else {
                scrollPoint.y += crawlingSpeed * CGFloat(timer.timeInterval)
                setContentOffset(scrollPoint, animated: true)
            }
        }
    }

    func stopCrawlingAnimation() {
        if isCrawling {
            scrollingTimer?.invalidate()
            starWarsDelegate?.starWarsTextViewDidStopCrawling(
                self,
                finished: false
            )
        }
    }

    // MARK: - View Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        updateInsets()
    }

    // MARK: - Internal API

    private func setupView() {
        isUserInteractionEnabled = false
        isScrollEnabled = false
        var transform = CATransform3DIdentity
        transform.m34 = -inclinationRatio / 500.0
        transform = CATransform3DRotate(
            transform, xAngle * .pi / 180.0,
            1.0,
            .zero,
            .zero
        )
        layer.transform = transform

        font = Fonts.load(.supercell, size: 14)
    }

    private func updateInsets() {
        let angleRatio = xAngle / 180.0
        let newInset = frame.size.height * (1 - angleRatio)
        var insets = contentInset

        if newInset != insets.top {
            insets.top = newInset
            insets.bottom = newInset
            contentInset = insets
        }
    }
}
