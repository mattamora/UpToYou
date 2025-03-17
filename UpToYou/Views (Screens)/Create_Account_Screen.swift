//
//  Create_Account_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/2/25.
//

import SwiftUI

struct Create_Account_Screen: View {
    
    @StateObject var newUser = CreateAccountViewModel()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                VStack {
                    Text("Create Account")
                        .foregroundStyle(.gray)
                        .font(.system(size: 50))
                        .bold()
                        .offset(y: 40)
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 50))
                        TextField("Full Name", text: $newUser.fullName)
                            .padding(.horizontal)
                            .frame(width: 300, height: 50)
                            .background(Color.white) // Gives it a visible background
                            .cornerRadius(20) // Rounds the edges
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 3) // Adds a border
                            )

                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 50))
                            .offset(y: 35)
                        TextField("Email", text: $newUser.email)
                            .padding(.horizontal)
                            .frame(width: 300, height: 50)
                            .background(Color.white) // Gives it a visible background
                            .cornerRadius(20) // Rounds the edges
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 3) // Adds a border
                            )
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                            .offset(y: 40)

                        Image(systemName: "lock.fill")
                            .foregroundStyle(.gray)
                            .font(.system(size: 50))
                            .offset(y: 70)
                        SecureField("Enter Password", text: $newUser.password)
                            .padding(.horizontal)
                            .frame(width: 300, height: 50)
                            .background(Color.white) // Gives it a visible background
                            .cornerRadius(20) // Rounds the edges
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 3) // Adds a border
                            )
                            .offset(y: 70)
                        
                        
                        Button {
                            newUser.create_account()
                        } label: {
                            Text("Sign Up  ➜")
                                .padding(.horizontal)
                                .frame(width: 160, height: 50)
                                .foregroundStyle(.white)
                                .font(.system(size: 25))
                                .background(Color.themeColor)
                                .cornerRadius(20)
                                .bold()
                        }
                        .offset(y: 100)
                        
                    } // end of form VStack
                    .padding()
                    .offset(y: -50)
                    
                    Spacer()
                } // end of VStack
                
                // error message popup for invalid fields
                if !newUser.errorMessage.isEmpty {
                    Text(newUser.errorMessage)
                        .foregroundStyle(Color.red)
                        .font(.system(size: 30))
                        .bold()
                    .offset(y: -250)
                }
            } // end of ZStack
        } // end of navigation stack
    } // end of body view
}

#Preview {
    Create_Account_Screen()
}
