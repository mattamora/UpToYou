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
    
    // for checking to see if the user is signed in upon opening the app
    @StateObject var is_Signed_In = SignedInViewModel()
    
    var body: some Scene {
        
        // goes to Home_Screen if user is signed in, Login_Screen otherwise
        WindowGroup {
            if is_Signed_In.isSignedIn, !is_Signed_In.currentUserID.isEmpty {
                Home_Screen()
            } else {
                Login_Screen()
            }
        }
    }
}
