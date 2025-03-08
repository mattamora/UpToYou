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
// used in Create_Account_Screen
class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    
    init() { }
    
    
    func Login() {
        
    }
}

