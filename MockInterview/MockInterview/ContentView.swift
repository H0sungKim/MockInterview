//
//  ContentView.swift
//  MockInterview
//
//  Created by 김호성 on 2025.05.19.
//

import SwiftUI

struct ContentView: View {
    @StateObject
    var viewModel = ConversationViewModel()
    
    var body: some View {
//        ConversationScreen().environmentObject(viewModel)
        InterviewScreen()
    }
}

#Preview {
    ContentView()
}
