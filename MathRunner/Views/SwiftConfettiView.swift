//
//  SwiftConfettiView.swift
//  MathRunner
//
//  Created by Matheus Gois on 27/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit
import QuartzCore

struct ConfettiManager {

    private let view: UIView

    init(superView: UIView) {
        view = .init(frame: superView.frame)
        view.isUserInteractionEnabled = false
        superView.addSubview(view)
    }

    mutating func start() {
        for layer in [foregroundConfettiLayer, backgroundConfettiLayer] {
            view.layer.addSublayer(layer)
            addBehaviors(to: layer)
            addAnimations(to: layer)
        }
    }

    private class ConfettiType {
        let color: UIColor
        let shape: ConfettiShape
        let position: ConfettiPosition

        init(color: UIColor, shape: ConfettiShape, position: ConfettiPosition) {
            self.color = color
            self.shape = shape
            self.position = position
        }

        let name = UUID().uuidString

        lazy var image: UIImage = {
            let imageRect: CGRect = {
                switch shape {
                case .rectangle:
                    return CGRect(x: 0, y: 0, width: 20, height: 13)
                case .circle:
                    return CGRect(x: 0, y: 0, width: 10, height: 10)
                }
            }()

            UIGraphicsBeginImageContext(imageRect.size)
            let context = UIGraphicsGetCurrentContext()!
            context.setFillColor(color.cgColor)

            switch shape {
            case .rectangle:
                context.fill(imageRect)
            case .circle:
                context.fillEllipse(in: imageRect)
            }

            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image!
        }()
    }

    private enum ConfettiShape {
        case rectangle
        case circle
    }

    private enum ConfettiPosition {
        case foreground
        case background
    }

    private var confettiTypes: [ConfettiType] = {
        let confettiColors: [UIColor] = [
            (149, 58, 255),
            (255, 195, 41),
            (255, 101, 26),
            (123, 92, 255),
            (76, 126, 255),
            (71, 192, 255),
            (255, 47, 39),
            (255, 91, 134),
            (233, 122, 208)
        ].map {
            UIColor(
                red: CGFloat($0.0) / 255.0,
                green: CGFloat($0.1) / 255.0,
                blue: CGFloat($0.2) / 255.0,
                alpha: 1
            )
        }

        let positions: [ConfettiPosition] = [.foreground, .background]
        let shapes: [ConfettiShape] = [.rectangle, .circle]

        return positions.flatMap { position in
            shapes.flatMap { shape in
                confettiColors.map { color in
                    return ConfettiType(color: color, shape: shape, position: position)
                }
            }
        }
    }()

    private func createConfettiCells() -> [CAEmitterCell] {
        return confettiTypes.map { confettiType in
            let cell = CAEmitterCell()
            cell.name = confettiType.name

            cell.beginTime = 0.1
            cell.birthRate = 100
            cell.contents = confettiType.image.cgImage
            cell.emissionRange = CGFloat(Double.pi)
            cell.lifetime = 10
            cell.spin = 4
            cell.spinRange = 8
            cell.velocityRange = 0
            cell.yAcceleration = 0

            cell.setValue("plane", forKey: "particleType")
            cell.setValue(Double.pi, forKey: "orientationRange")
            cell.setValue(Double.pi / 2, forKey: "orientationLongitude")
            cell.setValue(Double.pi / 2, forKey: "orientationLatitude")

            return cell
        }
    }

    /*
     Originally from https://bryce.co/caemitterbehavior/
     */
    private func createBehavior(type: String) -> NSObject {
        let behaviorClass = NSClassFromString("CAEmitterBehavior") as! NSObject.Type
        let behaviorWithType = behaviorClass.method(for: NSSelectorFromString("behaviorWithType:"))!
        let castedBehaviorWithType = unsafeBitCast(behaviorWithType, to: (@convention(c)(Any?, Selector, Any?) -> NSObject).self)
        return castedBehaviorWithType(behaviorClass, NSSelectorFromString("behaviorWithType:"), type)
    }

    private func horizontalWaveBehavior() -> Any {
        let behavior = createBehavior(type: "wave")
        behavior.setValue([100, 0, 0], forKeyPath: "force")
        behavior.setValue(0.5, forKeyPath: "frequency")
        return behavior
    }

    private func verticalWaveBehavior() -> Any {
        let behavior = createBehavior(type: "wave")
        behavior.setValue([0, 500, 0], forKeyPath: "force")
        behavior.setValue(3, forKeyPath: "frequency")
        return behavior
    }

    private func attractorBehavior(for emitterLayer: CAEmitterLayer) -> Any {
        let behavior = createBehavior(type: "attractor")
        behavior.setValue("attractor", forKeyPath: "name")

        behavior.setValue(-290, forKeyPath: "falloff")
        behavior.setValue(300, forKeyPath: "radius")
        behavior.setValue(10, forKeyPath: "stiffness")

        behavior.setValue(CGPoint(x: emitterLayer.emitterPosition.x,
                                  y: emitterLayer.emitterPosition.y + 20),
                          forKeyPath: "position")
        behavior.setValue(-70, forKeyPath: "zPosition")

        return behavior
    }

    private func addBehaviors(to layer: CAEmitterLayer) {
        layer.setValue([
            horizontalWaveBehavior(),
            verticalWaveBehavior(),
            attractorBehavior(for: layer)
        ], forKey: "emitterBehaviors")
    }

    private func addAttractorAnimation(to layer: CALayer) {
        let animation = CAKeyframeAnimation()
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = 3
        animation.keyTimes = [0, 0.4]
        animation.values = [80, 5]

        layer.add(animation, forKey: "emitterBehaviors.attractor.stiffness")
    }

    private func addBirthrateAnimation(to layer: CALayer) {
        let animation = CABasicAnimation()
        animation.duration = 1
        animation.fromValue = 1
        animation.toValue = 0

        layer.add(animation, forKey: "birthRate")
    }

    private func addAnimations(to layer: CAEmitterLayer) {
        addAttractorAnimation(to: layer)
        addBirthrateAnimation(to: layer)
        addGravityAnimation(to: layer)
    }

    private func dragBehavior() -> Any {
        let behavior = createBehavior(type: "drag")
        behavior.setValue("drag", forKey: "name")
        behavior.setValue(2, forKey: "drag")

        return behavior
    }

    private func addDragAnimation(to layer: CALayer) {
        let animation = CABasicAnimation()
        animation.duration = 0.35
        animation.fromValue = 0
        animation.toValue = 2

        layer.add(animation, forKey: "emitterBehaviors.drag.drag")
    }

    private func addGravityAnimation(to layer: CALayer) {
        let animation = CAKeyframeAnimation()
        animation.duration = 6
        animation.keyTimes = [0.05, 0.1, 0.5, 1]
        animation.values = [0, 100, 2000, 4000]

        for image in confettiTypes {
            layer.add(animation, forKey: "emitterCells.\(image.name).yAcceleration")
        }
    }

    private func createConfettiLayer() -> CAEmitterLayer {
        let emitterLayer = CAEmitterLayer()

        emitterLayer.birthRate = 0
        emitterLayer.emitterCells = createConfettiCells()
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.midX, y: view.bounds.minY - 100)
        emitterLayer.emitterSize = CGSize(width: 100, height: 100)
        emitterLayer.emitterShape = .sphere
        emitterLayer.frame = view.bounds

        emitterLayer.beginTime = CACurrentMediaTime()
        return emitterLayer
    }

    private lazy var foregroundConfettiLayer = createConfettiLayer()

    private lazy var backgroundConfettiLayer: CAEmitterLayer = {
        let emitterLayer = createConfettiLayer()

        for emitterCell in emitterLayer.emitterCells ?? [] {
            emitterCell.scale = 0.5
        }

        emitterLayer.opacity = 0.5
        emitterLayer.speed = 0.95

        return emitterLayer
    }()
}
