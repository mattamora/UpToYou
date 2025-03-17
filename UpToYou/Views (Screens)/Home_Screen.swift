//
//  Home_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 2/28/25.
//

/*
 REMOVE PUBLIC WHEN DONE WITH SWIFT NOTES AND APP IS CLOSE TO DONE
 currently using public for this view and its body so that Swift_Notes can access this
 */

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

public struct Home_Screen: View {
    // @StateObject var HomeViewModel = HomeScreenViewModel()
    
    // Navigation Purposes, no need for Home_Screen variable
    @State private var toList_Screen = false
    @State private var toProfile_Screen = false
    @State private var toShuffle_Screen = false
    @State private var toFavorites_Screen = false
    @State private var showLoginScreen = false
    @State private var showProfileScreen = false
    
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                VStack {
                
                    Text("Home")
                        .foregroundColor(.gray)
                    
                    // for shuffle or home screen? UI idea
                    // Text("What are you in the mood for?")
                    // then put a search bar
                    
                    // to Swift_Notes
                    // delete stack or move it when beginning implementation of this screen
                    NavigationStack {
                        NavigationLink(destination: swift_notes_code(),
                                       label: {Text("to Swift_notes") })
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
                            Image(systemName: "house.fill")
                                .resizable()
                                .frame(width: 33, height: 33)
                            Text("Home")
                                .font(.caption)
                                .underline()
                                .bold()
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
                                .onTapGesture { toFavorites_Screen = true }
                            Text("Favorites")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "person")
                                .resizable()
                                .frame(width: 33, height: 33)
                                .onTapGesture {toProfile_Screen = true}
                            Text("Profile")
                                .font(.caption)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .foregroundColor(.gray)
                    .navigationDestination(isPresented: $toList_Screen) {
                        List_Screen()
                            .navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $toProfile_Screen) {
                        Profile_Screen()
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
    Home_Screen()
}

