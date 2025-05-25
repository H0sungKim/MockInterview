//
//  MockInterviewApp.swift
//  MockInterview
//
//  Created by 김호성 on 2025.05.19.
//

import FirebaseAppCheck
import FirebaseCore
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        AppCheck.setAppCheckProviderFactory(AppCheckNotConfiguredFactory())
        FirebaseApp.configure()
        
        return true
    }
}

@main
struct MockInterviewApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}


/// Placeholder App Check provider factory that returns a simple ``AppCheckNotConfigured`` error.
private class AppCheckNotConfiguredFactory: NSObject, AppCheckProviderFactory {
  private class AppCheckNotConfiguredProvider: NSObject, AppCheckProvider {
    func getToken() async throws -> AppCheckToken {
      throw AppCheckNotConfigured()
    }
  }

  func createProvider(with app: FirebaseApp) -> (any AppCheckProvider)? {
    return AppCheckNotConfiguredProvider()
  }
}

/// Error indicating that App Check is not configured in the sample app.
struct AppCheckNotConfigured: Error {}
