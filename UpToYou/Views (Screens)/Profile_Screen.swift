//
//  Profile_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/1/25.
//

import SwiftUI
import MapKit

struct Profile_Screen: View {
    @StateObject var profileViewModel = ProfileScreenViewModel()
    
    // for handling location, viewing current location
    @StateObject private var locationManager = LocationManager()
    
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
                    
                    VStack {
                        if let currentUser = profileViewModel.currentUser {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200)
                                .foregroundStyle(Color.gray)
                            HStack {
                                Text("Name:")
                                Text(currentUser.name)
                            }
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                            .offset(y: 30)
                            HStack {
                                Text("Email:")
                                Text(currentUser.email)
                                    .underline()
                                    .lineLimit(1) // Keep on one line
                                    .minimumScaleFactor(0.5) // Shrinks the text if it's too long, max shrinkage is half
                            }
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                            .offset(y: 50)
                            .padding(.horizontal)
                            HStack {
                                Text("Joined on:")
                                Text(formattedDate(from: currentUser.joined))
                            }
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .offset(y: 70)
                            if locationManager.permissionDenied {
                                 Text("Location access denied. Please enable it in Settings.")
                                     .foregroundColor(.gray)
                                     .font(.system(size: 10))
                                     .offset(y: 70)
                             } else if let location = locationManager.cityAndState {
                                 Text("Current Location: \(location)")
                                     .foregroundColor(.gray)
                                     .font(.system(size: 10))
                                     .offset(y: 70)
                             } else {
                                 Text("Locating city...")
                                     .foregroundColor(.gray)
                                     .font(.system(size: 10))
                                     .offset(y: 70)
                             }
                            Button {
                                profileViewModel.logout()
                            } label : {
                                Text("Logout")
                                    .padding(.horizontal)
                                    .frame(width: 200, height: 70)
                                    .foregroundStyle(.white)
                                    .font(.system(size: 30))
                                    .background(Color.themeColor)
                                    .cornerRadius(20)
                                    .bold()
                            }
                            .padding(.top, 120)
                        } else {
                            Text("Loading Profile Screen...")
                                .foregroundColor(Color.mainColor)
                        }
                    }
                    .onAppear { profileViewModel.fetchUser() }
                    .offset(y: 50)
                    .navigationDestination(isPresented: $profileViewModel.isLoggedOut) {
                        Login_Screen()
                            .navigationBarBackButtonHidden(true)
                    }
                    
                    
                    
                    Spacer()
                    
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
                            Image(systemName: "shuffle.circle")
                                .resizable()
                                .frame(width: 37, height: 37)
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
                .onAppear {
                   // When the view appears, ask for location permission
                   // uses import MapKit
                   locationManager.checkLocationAuthorization()
               }
            } // end of ZStack
        } // end of Navigation Stack
    } // end of body view
} // end of Profile view

#Preview {
    Profile_Screen()
}
