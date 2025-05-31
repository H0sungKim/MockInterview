//
//  TTSGenerator.swift
//  MockInterview
//
//  Created by 김호성 on 2024.03.24.
//

import AVFoundation

class TTSGenerator {
    
    public static let shared = TTSGenerator()
    
    private let synthesizer = AVSpeechSynthesizer()
    
    private init() {
        synthesizer.usesApplicationAudioSession = true
    }
    
    func play(line: String) {
        let utterance = AVSpeechUtterance(string: line)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.4
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.speak(utterance)
    }
}
