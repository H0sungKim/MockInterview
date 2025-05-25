//
//  InterviewScreen.swift
//  MockInterview
//
//  Created by 김호성 on 2025.05.25.
//

import SwiftUI

struct InterviewScreen: View {
    var body: some View {
        Image(systemName: "microphone")
            .foregroundStyle(.white)
            .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
                print(pressing)
                switch pressing {
                case true:
                    Task {
                        do {
                            try await SpeechRecognizer.shared.startTranscribe()
                        } catch {
                            print("Failed to start transcription: \(error)")
                        }
                    }
                case false:
                    Task {
                        await SpeechRecognizer.shared.stopTranscribe()
                    }
                }
            }, perform: {
                
            })
    }
}

#Preview {
    InterviewScreen()
}
