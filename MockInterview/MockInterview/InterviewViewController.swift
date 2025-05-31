//
//  InterviewViewController.swift
//  MockInterview
//
//  Created by 김호성 on 2025.05.30.
//

import UIKit
import Combine

class InterviewViewController: UIViewController {
    
    @IBOutlet weak var userTranscript: UILabel!
    
    @IBOutlet weak var systemText: UITextView!
    private var speechRecognizer = SpeechRecognizer()
    
    private var cancellable = Set<AnyCancellable>()
    
    private var style: Int!
    private var job: String!
    private var pdfURL: URL!
    
    private var conversationViewModel: ConversationViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        speechRecognizer.transcript.sink(receiveValue: { [weak self] transcript in
            print("Transcript: \(transcript)")
            guard transcript != "" else { return }
            self?.userTranscript.text = "🔴 \(transcript)"
        })
        .store(in: &cancellable)
        
        conversationViewModel.$systemMessage
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] message in
//            print(message)
                self?.systemText.text = message
                TTSGenerator.shared.play(line: message)
        })
        .store(in: &cancellable)
        
        
        // Do any additional setup after loading the view.
    }
    
    func configure(style: Int, job: String) {
        self.style = style
        self.job = job
        conversationViewModel = ConversationViewModel(job: job, style: style)
    }

    @IBAction func test(_ sender: Any) {
        print("Test button tapped")
        TTSGenerator.shared.play(line: "Hello, I am your interviewer. Let's start the interview.")
    }
    @IBAction func touchDownMic(_ sender: UIButton) {
        print("Down")
        Task {
            do {
                try await speechRecognizer.startTranscribe()
            } catch {
                print("Failed to start transcription: \(error)")
            }
        }
        userTranscript.text = "🔴"
    }
    
    @IBAction func touchUpMic(_ sender: UIButton) {
        print("Up")
        Task {
            await speechRecognizer.stopTranscribe()
        }
        userTranscript.text = ""
        print("aa: \(speechRecognizer.transcript.value)")
        Task {
            await conversationViewModel.sendMessage(speechRecognizer.transcript.value)
        }
    }
}
