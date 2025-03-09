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
    
    // Navigation Purposes, no need for Profile_Screen
    @State private var toHome_Screen = false
    @State private var toList_Screen = false
    @State private var toShuffle_Screen = false
    @State private var toFavorites_Screen = false
    
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
                        .font(.system(size: 50))
                        .offset(y: -25)
                    TextField("Email", text: $user_login.email)
                        .padding(.horizontal)
                        .frame(width: 300, height: 50)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 3))
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .offset(y: -20)
                    
                    // Password field
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.gray)
                        .font(.system(size: 50))
                        .offset(y: -10)
                    SecureField("Enter Password", text: $user_login.password)
                        .padding(.horizontal)
                        .frame(width: 300, height: 50)
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
                            .frame(width: 160, height: 50)
                            .foregroundStyle(.white)
                            .font(.system(size: 25))
                            .background(Color.themeColor)
                            .cornerRadius(20)
                            .bold()
                            .offset(y: 15)
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
                    
                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                        .padding(.bottom, 20)
                    // bottom icons, navigation
                    HStack {
                        Spacer()
                        VStack {
                            Image(systemName: "house")
                                .resizable()
                                .frame(width: 33, height: 33)
                                .onTapGesture {toHome_Screen = true}
                            Text("Home")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "list.bullet.circle")
                                .resizable()
                                .frame(width: 33, height: 33)
                                .onTapGesture {toList_Screen = true}
                            Text("List")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "arrow.trianglehead.2.clockwise")
                                .resizable()
                                .frame(width: 33, height: 33)
                                .onTapGesture {toShuffle_Screen = true}
                            Text("Shuffle")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "heart")
                                .resizable()
                                .frame(width: 33, height: 33)
                                .onTapGesture {
                                    toFavorites_Screen = true
                                    print("Tapped")
                                }
                            Text("Favorites")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 33, height: 33)
                            Text("Profile")
                                .font(.caption)
                                .underline()
                                .bold()
                        }
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .foregroundColor(.gray)
                    .navigationDestination(isPresented: $toHome_Screen) {
                        Home_Screen()
                            .navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $toList_Screen) {
                        List_Screen()
                            .navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $toShuffle_Screen) {
                        Shuffle_Screen()
                            .navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $toFavorites_Screen) {
                        Favorites_Screen()
                            .navigationBarBackButtonHidden(true)
                    }
                    
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
