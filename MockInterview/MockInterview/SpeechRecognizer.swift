//
//  STTManager.swift
//  MockInterview
//
//  Created by 김호성 on 2025.05.25.
//

import Foundation
import AVFoundation
import Speech
import Combine

actor SpeechRecognizer {
    
    @MainActor var transcript: CurrentValueSubject<String, Never> = .init("")
    private let recognizer = SFSpeechRecognizer(locale: Locale(identifier: "en_US"))
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var isRecording = false
    
    init() {
        Task {
            await requestAuthorization()
        }
    }
    
    func requestAuthorization() async {
        // Authorization Speech Recognizer
        let speechAuthStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        speechAuthStatus == .authorized
        ? print("음성 인식 권한이 허용되었습니다.")
        : print("음성 인식 권한이 허용되지 않았습니다.")
        
        // Authorization Audio Session
        let audioAuthStatus = await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { status in
                continuation.resume(returning: status)
            }
        }
        audioAuthStatus
        ? print("오디오 녹음 권한이 허용되었습니다.")
        : print("오디오 녹음 권한이 허용되지 않았습니다.")
    }
    
    func startTranscribe() async throws {
        guard let recognizer, recognizer.isAvailable else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            throw error
        }
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.addsPunctuation = true
        self.request = request
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }
        self.audioEngine.prepare()
        try self.audioEngine.start()
        
        self.recognitionTask = recognizer.recognitionTask(
            with: request
        ) { [weak self] result, error in
            if let result {
                let transcription = result.bestTranscription.formattedString
                Task { @MainActor in
                    await self?.transcript.send(transcription)
                }
            }
        }
    }
    
    func stopTranscribe() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print("Error : \(error), \(error.userInfo)")
        }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionTask?.cancel()
        recognitionTask = nil
        
        request?.endAudio()
        request = nil
    }
}
