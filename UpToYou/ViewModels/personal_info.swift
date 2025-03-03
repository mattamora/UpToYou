//
//  personal_info.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/2/25.
//
// ViewModel for Profile_Screen
// Contains login info 

import SwiftUI


// for login and create an account
class LoginViewViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    init() { }
}
