//
//  Login_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/7/25.
//

import SwiftUI

struct Login_Screen: View {
    
    // Navigation Purposes, no need for Profile_Screen
    @State private var toHome_Screen = false
    @State private var toList_Screen = false
    @State private var toShuffle_Screen = false
    @State private var toFavorites_Screen = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                VStack {
                    Text("Login")
                        .foregroundStyle(.gray)
                        .font(.system(size: 50))
                        .bold()
                        .offset(y: 80)
                    
                    Spacer()
                    
                    // to account registration page
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)
                        NavigationLink(destination: Create_Account_Screen(),
                                       label: {
                            Text("Sign Up")
                                .underline()
                                .foregroundStyle(Color.themeColor)
                        })
                    }
                    
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
            } // end of ZStack
        } // end of Navigation Stack
    } // end of body view
} // end of Profile view

#Preview {
    Login_Screen()
}
