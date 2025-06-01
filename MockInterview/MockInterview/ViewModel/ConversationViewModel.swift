// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import FirebaseVertexAI
import Foundation
import UIKit

@MainActor
class ConversationViewModel: ObservableObject {
    /// This array holds both the user's and the system's chat messages
    @Published var messages = [ChatMessage]()
    
    @Published var systemMessage: String = ""
    
    /// Indicates we're waiting for the model to finish
    @Published var busy = false
    
    @Published var error: Error?
    var hasError: Bool {
        return error != nil
    }
    
    private var model: GenerativeModel
    private var chat: Chat
    private var stopGenerating = false
    
    private var chatTask: Task<Void, Never>?
    
    
    init(job: String, style: Int) {
        model = VertexAI.vertexAI().generativeModel(modelName: "gemini-2.0-flash-001")
//        chat = model.startChat()
        chat = model.startChat(history: [
            ModelContent(role: "user", parts: """
                You are a human interviewer hiring \(job).
                Conduct a realistic mock interview by asking one question at a time, based on the candidate's answers.
                Wait for my answer and then provide brief, natural feedback on my response just as a real interviewer would.
                Maintain a. onversational tone with a level of formality around \(style), where 0 is very stiff/formal and 10 is casual/friendly.
                Act as a professional human interviewer, not a chatbot.
                Please start as soon as I tell you "I'm ready".
            """),
        ])
    }
    
    func sendMessage(_ text: String, streaming: Bool = true) async {
        error = nil
        if streaming {
            await internalSendMessageStreaming(text)
        } else {
            await internalSendMessage(text)
        }
    }
    
    func startNewChat() {
        stop()
        error = nil
        chat = model.startChat()
        messages.removeAll()
    }
    
    func stop() {
        chatTask?.cancel()
        error = nil
    }
    
    private func internalSendMessageStreaming(_ text: String) async {
        chatTask?.cancel()
        systemMessage = ""
        
        chatTask = Task {
            busy = true
            defer {
                busy = false
            }
            
            // first, add the user's message to the chat
            let userMessage = ChatMessage(message: text, participant: .user)
            messages.append(userMessage)
            
            // add a pending message while we're waiting for a response from the backend
            let systemMessage = ChatMessage.pending(participant: .system)
            messages.append(systemMessage)
            
            do {
                let responseStream = try chat.sendMessageStream(text)
                for try await chunk in responseStream {
                    messages[messages.count - 1].pending = false
                    if let text = chunk.text {
                        messages[messages.count - 1].message += text
                        self.systemMessage += text
                    }
                }
            } catch {
                self.error = error
                print(error.localizedDescription)
                messages.removeLast()
            }
        }
    }
    
    private func internalSendMessage(_ text: String) async {
        chatTask?.cancel()
        
        chatTask = Task {
            busy = true
            defer {
                busy = false
            }
            
            // first, add the user's message to the chat
            let userMessage = ChatMessage(message: text, participant: .user)
            messages.append(userMessage)
            
            // add a pending message while we're waiting for a response from the backend
            let systemMessage = ChatMessage.pending(participant: .system)
            messages.append(systemMessage)
            
            do {
                var response: GenerateContentResponse?
                response = try await chat.sendMessage(text)
                
                if let responseText = response?.text {
                    // replace pending message with backend response
                    messages[messages.count - 1].message = responseText
                    messages[messages.count - 1].pending = false
                }
            } catch {
                self.error = error
                print(error.localizedDescription)
                messages.removeLast()
            }
        }
    }
    
    func sendPDF(text: String, pdfURL: URL) async {
        chatTask?.cancel()
        
        chatTask = Task {
            busy = true
            defer {
                busy = false
            }
            
            // first, add the user's message to the chat
            let userMessage = ChatMessage(message: text, participant: .user)
            messages.append(userMessage)
            
            // add a pending message while we're waiting for a response from the backend
            let systemMessage = ChatMessage.pending(participant: .system)
            messages.append(systemMessage)
            
            do {
                // Provide the PDF as `Data` with the appropriate MIME type
                let pdf = try InlineDataPart(data: Data(contentsOf: pdfURL), mimeType: "application/pdf")

                

                // To generate text output, call `generateContent` with the PDF file and text prompt
                let response: GenerateContentResponse = try await model.generateContent(pdf, text)
                chat.history.append(ModelContent(parts: """
                    This is my portfolio.
                    Please remember and ask questions that are relevant to this when conducting the mock interview.
                    \(response.text ?? "")
                """))
                // Print the generated text, handling the case where it might be nil
                print(response.text ?? "No text in response.")
                
                messages[messages.count - 1].message = response.text ?? ""
                messages[messages.count - 1].pending = false
            } catch {
                self.error = error
                print(error.localizedDescription)
                messages.removeLast()
            }
        }
    }
}
