//
//  ToggleSwitch.swift
//  MathRunner
//
//  Created by Matheus Gois on 20/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import SwiftUI
import UIKit

protocol ToggleSwitchProtocol: AnyObject {
    func didTap(isOn: Bool)
}

struct ToggleSwitch: View {

    @State var isOn: Bool {
        didSet {
            delegate?.didTap(isOn: isOn)
        }
    }

    weak var delegate: ToggleSwitchProtocol?

    private let baseColor: Color = Color(#colorLiteral(red: 0.003921568627, green: 0.937254902, blue: 0.01176470588, alpha: 1))
    private let shadowColor: Color = Color(#colorLiteral(red: -0.12391605228185654, green: 0.7561009526252747, blue: -0.004064709413796663, alpha: 1.0))

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .frame(width: 80, height: 44)
                .foregroundColor(
                    Color(isOn ?
                          #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.09863945578231292) :
                            #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.258875425170068)
                         )
                )

            HStack {
                Text("  ON")
                    .font(Fonts.load(.supercell, size: 12))
                    .foregroundColor(.white)
                Spacer()
                Text("OFF ")
                    .font(Fonts.load(.supercell, size: 12))
                    .foregroundColor(.white)
            }
            .frame(width: 80, height: 44)

            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        baseColor.gradient.shadow(
                            .inner(
                                color: shadowColor,
                                radius: 0,
                                x: 0,
                                y: -4
                            )
                        )
                    )
                    .frame(width: 36, height: 36)
            }
            .frame(width: 80, height: 44)
            .offset(x: isOn ? 18 : -18)
            .padding(24)
            .animation(.spring())
        }
        .onTapGesture {
            impactOccurred()
            self.isOn.toggle()
        }
    }
}

final class ToggleSwitchView: UIView, ToggleSwitchProtocol {

    var action: ((_ isOn: Bool) -> Void)?

    var isActived: Bool = true {
        didSet {
            commonSetup()
        }
    }

    private lazy var swiftUIView = ToggleSwitch(isOn: isActived, delegate: self)

    func didTap(isOn: Bool) {
        action?(isOn)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func commonSetup() {
        let hostingController = UIHostingController(rootView: swiftUIView)

        backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
