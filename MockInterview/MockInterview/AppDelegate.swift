//
//  AppDelegate.swift
//  MockInterview
//
//  Created by 김호성 on 2025.05.30.
//

import FirebaseAppCheck
import FirebaseCore
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AppCheck.setAppCheckProviderFactory(AppCheckNotConfiguredFactory())
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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
