//
//  UpToYouApp.swift
//  UpToYou
//
//  Created by Matthew Amora on 2/28/25.
//  App startup

import SwiftUI
import FirebaseCore

// Firebase stuff
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct UpToYouApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    
    var body: some Scene {
        
        // goes to Home_Screen if user is signed in, Login_Screen otherwise
        WindowGroup {
            Home_Screen()
        }
    }
}
