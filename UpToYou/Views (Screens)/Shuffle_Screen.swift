//
//  Shuffle_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/1/25.
//


import SwiftUI
import MapKit

struct Shuffle_Screen: View {
    
    @StateObject private var ShuffleViewModel = ShuffleScreenViewModel()
    
    // Navigation Purposes, no need for Shuffle_Screen
    @State private var toHome_Screen = false
    @State private var toList_Screen = false
    @State private var toProfile_Screen = false
    @State private var toFavorites_Screen = false

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                VStack {
                    
                    
                    // bottom icons, navigation
                    Spacer()
                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                        .padding(.bottom, 20)
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
                            Image(systemName: "shuffle.circle.fill")
                                .resizable()
                                .frame(width: 37, height: 37)
                            Text("Shuffle")
                                .font(.caption)
                                .underline()
                                .bold()
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
                                .onTapGesture { toProfile_Screen = true }
                            Text("Profile")
                                .font(.caption)
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
                    .navigationDestination(isPresented: $toProfile_Screen) {
                        Profile_Screen()
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
    Shuffle_Screen()
}
