//
//  Login_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/7/25.
//

/*
NEED TO REMOVE BOTTOM ICONS WHEN APP IS CLOSE
TO BEING DONE
*/

import SwiftUI

struct Login_Screen: View {
    
    // For account login, info
    @StateObject var user_login = LoginViewModel()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                VStack {
                    Text("Login")
                        .foregroundStyle(.gray)
                        .font(.system(size: 50))
                        .bold()
                        .offset(y: 40)
                     
                    Spacer()
                    
                    // Email/username field
                    Image(systemName: "envelope.fill")
                        .foregroundStyle(.gray)
                        .font(.system(size: 60))
                        .offset(y: -30)
                    TextField("Email", text: $user_login.email)
                        .padding(.horizontal)
                        .frame(width: 300, height: 70)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 3))
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .offset(y: -25)
                    
                    // Password field
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.gray)
                        .font(.system(size: 60))
                        .offset(y: -10)
                    SecureField("Enter Password", text: $user_login.password)
                        .padding(.horizontal)
                        .frame(width: 300, height: 70)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 3))
                        .offset(y: -10)
                    
                    // Login Button
                    Button {
                        user_login.Login()
                    } label: {
                        Text("Login  ➜")
                            .padding(.horizontal)
                            .frame(width: 200, height: 70)
                            .foregroundStyle(.white)
                            .font(.system(size: 25))
                            .background(Color.themeColor)
                            .cornerRadius(20)
                            .bold()
                            .offset(y: 20)
                    }
                    .navigationDestination(isPresented: $user_login.isLoggedIn) {
                        Profile_Screen()
                            .navigationBarBackButtonHidden(true)
                    }
                    
                    // to Create_Account_Screen page
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                            .font(.system(size: 15))
                        NavigationLink(destination: Create_Account_Screen(),
                                       label: {
                            Text("Sign Up")
                                .underline()
                                .foregroundStyle(Color.themeColor)
                                .font(.system(size: 15))
                        })
                    }
                    .offset(y: 90)
                    
                    Spacer()
                
                } // end of VStack
                
                // error message popup for invalid fields
                if !user_login.errorMessage.isEmpty {
                    Text(user_login.errorMessage)
                        .foregroundStyle(Color.red)
                        .font(.system(size: 30))
                        .bold()
                    .offset(y: -240)
                }
            } // end of ZStack
        } // end of Navigation Stack
    } // end of body view
} // end of Profile view

#Preview {
    Login_Screen()
}
