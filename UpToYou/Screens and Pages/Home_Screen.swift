//
//  Home_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 2/28/25.
//

import SwiftUI

struct Home_Screen: View {
    
    var mainColor = Color(hue: 1.0, saturation: 0.183, brightness: 0.092)
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                mainColor.ignoresSafeArea()

                VStack {
                    
                    Text("Up To You")
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                        .padding(.bottom, 20)
                    
                    // bottom icons, navigation
                    HStack {
                        Spacer()
                        VStack {
                            NavigationLink(
                                destination: Home_Screen(),
                                label: {
                                  Image(systemName: "house")
                                      .resizable()
                                      .frame(width: 33, height: 33)
                            })
                            Text("Home")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            NavigationLink(
                                destination: List_Screen(),
                                label: {
                                  Image(systemName: "list.bullet.circle")
                                      .resizable()
                                      .frame(width: 33, height: 33)
                            })
                            Text("List")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            NavigationLink(
                                destination: Shuffle_Screen(),
                                label: {
                                  Image(systemName: "arrow.trianglehead.2.clockwise")
                                      .resizable()
                                      .frame(width: 33, height: 33)
                            })
                            Text("Shuffle")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            NavigationLink(
                                destination: Favorites_Screen(),
                                label: {
                                  Image(systemName: "heart")
                                      .resizable()
                                      .frame(width: 33, height: 33)
                            })
                            Text("Favorites")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            NavigationLink(
                                destination: Profile_Screen(),
                                label: {
                                  Image(systemName: "person")
                                      .resizable()
                                      .frame(width: 33, height: 33)
                            })
                            Text("Profile")
                                .font(.caption)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .foregroundColor(.gray)

                } // end of VStack
            } // end of ZStack
        } // end of Navigation Stack
    } // end of body view
} // end of Home_Screen view




#Preview {
    Home_Screen()
}

