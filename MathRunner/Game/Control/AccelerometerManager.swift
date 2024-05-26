//
//  MotionGesture.swift
//  MathRunner
//
//  Created by Matheus Gois on 21/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit
import CoreMotion

final class AccelerometerManager {

    private init() {}
    static let shared = AccelerometerManager()

    private var timer: Timer?

    var handler: ((RunDirection) -> Void)?

    var hasMoved: Bool = false

    func start() {
        timer = Timer.scheduledTimer(
            timeInterval: 0.1,
           target: self,
           selector: #selector(handleAcceleration),
           userInfo: nil,
           repeats: true
       )
    }

    func stop() {
        timer?.invalidate()
    }

    let motionManager: CMMotionManager = {
        let motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()

        return motionManager
    }()

    @objc private func handleAcceleration() {
        func move(_ direction: RunDirection) {
            guard !hasMoved else { return }
            Debug.print(direction.rawValue)
            hasMoved = true
            handler?(direction)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.hasMoved = false
            }
        }

        if let accelerometerData = motionManager.accelerometerData {
            if accelerometerData.acceleration.y > 0.2 {
                Debug.print("jump")
                handler?(.up)
            }

            if accelerometerData.acceleration.x <= -0.6 {
                move(.left)
            }

            if accelerometerData.acceleration.x >= 0.6 {
                move(.right)
            }

//            print(accelerometerData)
        }
    }
}

// Enum para representar direções de aceleração
enum AccelerationDirection {
    case leftRight
    case frontBack
    case upDown
}
