//
//  List_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/1/25.
//

import SwiftUI

struct List_Screen: View {
    
    // Navigation Purposes, no need for List_Screen
    @State private var toHome_Screen = false
    @State private var toProfile_Screen = false
    @State private var toShuffle_Screen = false
    @State private var toFavorites_Screen = false
    
    @StateObject var listViewModel = ListScreenViewModel()

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                VStack {
                    
                    Text("List")
                        .foregroundColor(.gray)
                    
                    Text("Gonna be used as a placeholder to add to favorites for now")
                        .foregroundColor(.gray)
                    
                    VStack { // using a vstack to modify form height
                        Text("This form adds sample data into firebase")
                        Form {
                            // TextField for single line inputs, can't change height
                            TextField("Sample Restaurant", text:$listViewModel.restoName)
                            TextField("Sample Picture", text:$listViewModel.picture)
                            TextField("Sample Location", text:$listViewModel.location)
                            
                            Button {
                                listViewModel.saveToFirebase()
                                
                            } label : {
                                Text("Save data to firebase favorites collection")
                            }
                        }
                    }
                    .frame(height: 300)
                    .padding(.top, 20)
                    
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
                            Image(systemName: "list.bullet.circle.fill")
                                .resizable()
                                .frame(width: 33, height: 33)
                            Text("List")
                                .font(.caption)
                                .underline()
                                .bold()
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
                    .navigationDestination(isPresented: $toHome_Screen) {
                        Home_Screen()
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
    List_Screen()
}
