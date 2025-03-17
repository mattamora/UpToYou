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
    
    // authentication state tracker, check if a user is logged in
    @StateObject var authViewModel = AuthViewModel()
    
    
    // goes to Login_Screen if no user is logged in, Home_Screen otherwise
    var body: some Scene {
        WindowGroup {
            if authViewModel.isSignedIn {
               Home_Screen()
           } else {
               Login_Screen()
           }
        }
    }
}
