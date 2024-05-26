//
//  KeyCommands.swift
//  MathRunner
//
//  Created by Matheus Gois on 25/12/23.
//  Copyright © 2023 Matheus Gois. All rights reserved.
//

import UIKit

extension UIViewController {
    open override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        var didHandleEvent = false
        for press in presses {
            guard let key = press.key else { continue }
            if key.charactersIgnoringModifiers == UIKeyCommand.inputLeftArrow {
                Self.handleKeyboard?(.left)
                didHandleEvent = true
            }
            if key.charactersIgnoringModifiers == UIKeyCommand.inputRightArrow {
                Self.handleKeyboard?(.right)
                didHandleEvent = true
            }
            if key.charactersIgnoringModifiers == UIKeyCommand.inputUpArrow {
                Self.handleKeyboard?(.up)
                didHandleEvent = true
            }
            if key.charactersIgnoringModifiers == UIKeyCommand.inputDownArrow {
                Self.handleKeyboard?(.down)
                didHandleEvent = true
            }
        }

        if didHandleEvent == false {
            super.pressesBegan(presses, with: event)
        }
    }

    static var handleKeyboard: ((_ direction: RunDirection) -> Void)?
}
