//
//  Fonts.swift
//  MathRunner
//
//  Created by Matheus Gois on 17/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import UIKit
import SwiftUI
import CoreText

// Error type for font management errors
enum FontManageableError: Error {
    case couldNotLoadFont(String)
    case couldNotCreateFont
    case couldNotRegisterFont(with: CFError?)
}

// Protocol defining font management methods
protocol FontManageable {
    var resourceName: String { get }
    var resourceType: String { get }

    func registerFont() throws
}

// Extension for the FontManageable protocol
extension FontManageable {
    func getURL() throws -> URL {
        // Create a URL for the font resource
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: resourceType) else {
            throw FontManageableError.couldNotLoadFont(resourceName)
        }
        return url
    }

    func registerFont() throws {
        // Get the URL for the font resource
        let url = try getURL()

        // Create a data provider for the font
        guard let fontDataProvider = CGDataProvider(url: url as CFURL) else {
            throw FontManageableError.couldNotLoadFont(resourceName)
        }

        // Create a CGFont from the data provider
        guard let font = CGFont(fontDataProvider) else {
            throw FontManageableError.couldNotCreateFont
        }

        // Register the font with the CTFontManager
        var errorRef: Unmanaged<CFError>?

        guard CTFontManagerRegisterGraphicsFont(font, &errorRef) else {
            throw FontManageableError.couldNotRegisterFont(with: errorRef?.takeRetainedValue())
        }
    }
}

struct Fonts {

    static func register() {
        do {
            try Fonts.FontType.supercell.registerFont()

            Debug.print("Fonts registered successfully!")
        } catch let error {
            Debug.print("Error registering fonts: \(error)")
        }
    }

    static func load(
        _ type: FontType,
        size: CGFloat
    ) -> UIFont {
        let font: UIFont
        if let customFont = UIFont(
            name: type.fontName,
            size: size
        ) {
            font = customFont
        } else {
            assertionFailure("error")
            font = UIFont.systemFont(ofSize: size)
        }

        return font
    }

    static func load(
        _ type: FontType,
        size: CGFloat
    ) -> Font {
        let font: Font
        if let customFont = UIFont(
            name: type.fontName,
            size: size
        ) {
            font = .init(customFont)
        } else {
            assertionFailure("error")
            font = .init(UIFont.systemFont(ofSize: size))
        }

        return font
    }
}

extension Fonts {
    enum FontType: String, FontManageable {
        case supercell = "Supercell-Magic"

        var resourceName: String { rawValue }
        var resourceType: String { "otf" }

        var fontName: String {
            switch self {
            case .supercell:
                return "Supercell-Magic"
            }
        }
    }
}
