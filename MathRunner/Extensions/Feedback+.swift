//
//  Feedback+.swift
//  MathRunner
//
//  Created by Matheus Gois on 22/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import Foundation
import UIKit

func impactOccurred() {
    guard DataStorage.hapticIsActive else { return }
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
}
