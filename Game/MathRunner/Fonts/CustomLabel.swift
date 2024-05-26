//
//  CustomLabel.swift
//  MathRunner
//
//  Created by Matheus Gois on 17/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit
import SceneKit

class CustomLabel: UILabel {

    var strokeWidth: CGFloat = -5 {
        didSet {
            commonInit()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        textColor = .white
        textAlignment = .center
        shadowColor = UIColor.black
        backgroundColor = UIColor.clear
        lineBreakMode = .byWordWrapping

        let strokeTextAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.strokeWidth: strokeWidth
        ]
        attributedText = NSAttributedString(
            string: text ?? "",
            attributes: strokeTextAttributes
        )

        font = Fonts.load(.supercell, size: font.pointSize)
    }
}

extension CustomLabel {
    static func createSCNText(text: String, size: CGFloat) -> SCNNode {
        let textGeometry = SCNText(string: text, extrusionDepth: 1)
        textGeometry.font = Fonts.load(.supercell, size: size)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.white
        textGeometry.firstMaterial?.isDoubleSided = true

        let textNode = SCNNode(geometry: textGeometry)
        textNode.castsShadow = true

        let (min, max) = textNode.boundingBox
        let dx: Float = Float(min.x - max.x) / 2.0
        let dy: Float = Float(min.y - max.y)
        textNode.position = SCNVector3Make(dx, dy, 1)

        return textNode
    }
}

final class UpdateLabel: CustomLabel {

    private var displayLink: CADisplayLink?
    private var currentValue: Int = 0
    private var toValue: Int = 0
    private var step: Int = 1

    func animate(to value: Int, step: Int = 1) {
        stopAnimation()

        currentValue = Int(text ?? "") ?? .zero
        toValue = value

        self.step = currentValue < toValue ? step : -step

        displayLink = CADisplayLink(target: self, selector: #selector(updateLabel))
        displayLink?.add(to: .main, forMode: .common)
    }

    private func stopAnimation() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func updateLabel() {
        self.text = .init("0000\(currentValue)".suffix(4))
        if currentValue == toValue {
            stopAnimation()
        }
        currentValue += step
    }
}
