//
//  AudioManager.swift
//  MathRunner
//
//  Created by Matheus Gois on 30/01/24.
//  Copyright © 2024 Matheus Gois. All rights reserved.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private init() { }

    private var audioPlayers: [Music: AVAudioPlayer] = [:]
    private var playerSteps: [Player: AVAudioPlayer] = [:]
    private let playerStepsCount = 10

    var soundIsActive: Bool = true {
        didSet {
            scenarioIsActive = soundIsActive
            playerStepIsActive = soundIsActive
        }
    }

    var scenarioIsActive: Bool = true {
        didSet {
            AudioManager.shared.audioPlayers.forEach {
                $0.1.volume = scenarioIsActive ? $0.0.volume : .zero
            }
        }
    }

    var playerStepIsActive: Bool = true {
        didSet {
            AudioManager.shared.playerSteps.forEach {
                $0.1.volume = playerStepIsActive ? $0.0.volume : .zero
            }
        }
    }

    var isAmbientActive: Bool = true {
        didSet {
            guard DataStorage.soundIsActive else { return }
            AudioManager.shared.audioPlayers[.musicAmbience]?.volume = isAmbientActive ? Music.musicAmbience.volume : .zero
        }
    }

    var isAmbientVolumeMax: Bool = false {
        didSet {
            guard DataStorage.soundIsActive else { return }
            AudioManager.shared.audioPlayers[.musicAmbience]?.volume = isAmbientVolumeMax ? Music.musicAmbience.volume * 2 : Music.musicAmbience.volume
        }
    }

    func preloadAudio() {
        loadPlayerSounds()
        preloadAmbientAudio()
    }

    func preloadAmbientAudio() {
        for music in Music.allCases {
            guard let audioPath = Bundle.main.path(
                forResource: music.rawValue,
                ofType: music.type
            ) else {
                Debug.print("Erro ao encontrar o arquivo de áudio")
                return
            }

            let audioURL = URL(fileURLWithPath: audioPath)

            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer.prepareToPlay()
                audioPlayer.volume = music.volume
                audioPlayers[music] = audioPlayer
            } catch {
                Debug.print("Erro ao carregar o áudio: \(error.localizedDescription)")
            }
        }
    }

    func play(_ music: Music) {
        guard DataStorage.soundIsActive else { return }
        DispatchQueue.main.async {
            guard
                DataStorage.soundIsActive,
                let audioPlayer = self.audioPlayers[music]
            else {
                return
            }

            if music.isInfinity {
                audioPlayer.numberOfLoops = -1
            }
            audioPlayer.currentTime = .zero
            audioPlayer.stop()
            audioPlayer.play()
        }
    }
}

// MARK: - Player

extension AudioManager {
    func playFootStep() {
        guard DataStorage.soundIsActive else { return }
        DispatchQueue.main.async {
            let randSnd: Int = .init(Float(arc4random()) / Float(RAND_MAX) * Float(self.playerStepsCount))
            let stepSoundIndex: Int = min(self.playerStepsCount - 1, randSnd)

            if
                let value = Player(stepSoundIndex),
                let audioPlayer = self.playerSteps[value]
            {
                audioPlayer.currentTime = .zero
                audioPlayer.play()
            }
        }
    }

    func loadPlayerSounds() {
        for music in Player.allCases {
            guard let audioPath = Bundle.main.path(
                forResource: music.rawValue,
                ofType: music.type
            ) else {
                Debug.print("Erro ao encontrar o arquivo de áudio")
                return
            }

            let audioURL = URL(fileURLWithPath: audioPath)

            do {
                let audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                audioPlayer.prepareToPlay()
                audioPlayer.volume = music.volume
                playerSteps[music] = audioPlayer
            } catch {
                Debug.print("Erro ao carregar o áudio: \(error.localizedDescription)")
            }
        }
    }
}

extension AudioManager {
    enum Music: String, CaseIterable {
        case jump
        case collect
        case collectBig
        case hit
        case musicVictory
        case musicAmbience

        var type: String {
            switch self {
            case .musicVictory, .musicAmbience, .hit:
                return "mp3"
            default:
                return "m4a"
            }
        }

        var volume: Float {
            switch self {
            case .jump, .hit, .collectBig:
                return 0.7
            case .collect:
                return 0.2
            case .musicAmbience:
                return 0.1
            case .musicVictory:
                return 0.7
            }
        }

        var isInfinity: Bool {
            switch self {
            case .musicAmbience:
                return true
            default:
                return false
            }
        }
    }

    enum Player: String, CaseIterable {
        case playerStep0
        case playerStep1
        case playerStep2
        case playerStep3
        case playerStep4
        case playerStep5
        case playerStep6
        case playerStep7
        case playerStep8
        case playerStep9

        init?(_ value: Int) {
            guard let player = Player(rawValue: "playerStep\(value)") else { return nil }
            self = player
        }

        var type: String {
            switch self {
            default:
                return "mp3"
            }
        }

        var volume: Float {
            return 0.2
        }
    }
}
