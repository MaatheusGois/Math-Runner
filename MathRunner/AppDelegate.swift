//
//  AppDelegate.swift
//  MathRunner
//
//  Created by Matheus Gois on 24/12/23
//  Copyright © 2018 Matheus Gois. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Fonts.register()
        Coordinator.shared.start()
        AudioManager.shared.preloadAudio()

        DataStorage.soundIsActive = true
        Debug.enabled = true

        return true
    }
}
