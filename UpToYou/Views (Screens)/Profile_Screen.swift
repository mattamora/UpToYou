//
//  Profile_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/1/25.
//

import SwiftUI

struct Profile_Screen: View {
    
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
                    
                    Text("Profile")
                        .foregroundColor(.gray)
                    
                    Text("Logged In")
                        .foregroundColor(.gray)
                        .bold()
                        .offset(y: 20)
                    
                    
                    Spacer()
                    
                    
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
    Profile_Screen()
}
