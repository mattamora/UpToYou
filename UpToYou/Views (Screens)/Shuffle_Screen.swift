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
    
    // for handling location
    @StateObject private var locationManager = LocationManager()
    
    // Navigation Purposes, no need for Shuffle_Screen
    @State private var toHome_Screen = false
    @State private var toList_Screen = false
    @State private var toProfile_Screen = false
    @State private var toFavorites_Screen = false
    
    // for the distance filter selection
    @State private var showDistanceSheet = false
    @State private var selectedDistance = 5
    let distanceOptions = [5, 10, 15, 20, 25]
    
    // for type of food filter
    @State private var showFoodSheet = false
    @State private var selectedFoodType: FoodType = .any // enum in Structs&Extensions

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                VStack {
                    // filter buttons
                    HStack {
                        Button {
                            showDistanceSheet = true
                        } label: {
                            HStack (spacing: 5) {
                                Image(systemName: "location")
                                Text("Within: \(selectedDistance) miles")
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .foregroundColor(Color.gray)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            
                        }
                        
                        Button {
                            showFoodSheet = true
                        } label : {
                            HStack (spacing: 5) {
                                Image(systemName: "fork.knife")
                                Text("Food Type: \(selectedFoodType.rawValue)")
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .foregroundColor(Color.gray)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            
                        }
                    }
                    
                    // uses Yelp API to fetch restaurants, in order of distance
                    Button {
                        if let location = locationManager.userLocation {
                            ShuffleViewModel.fetchYelpRestaurants(
                                latitude: location.latitude,
                                longitude: location.longitude,
                                distanceInMiles: selectedDistance,
                                foodType: selectedFoodType
                            )
                        }
                    } label: {
                        Text("Fetch Nearby Restaurants")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                    .disabled(locationManager.userLocation == nil)

                    // loading or empty text
                    if ShuffleViewModel.isLoading {
                        ProgressView("Loading...")
                    } else if ShuffleViewModel.restaurants.isEmpty {
                        Text("No Restaurants Nearby!")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        
                        List(ShuffleViewModel.restaurants, id: \.url) { resto in
                            let itemModel = ShuffleViewModel.convertToFavoriteModel(resto)

                            Favorite_Item(item: itemModel)
                                .listRowInsets(EdgeInsets()) // Removes default List padding
                                .frame(maxWidth: .infinity)
                                .listRowSeparatorTint(.white, edges: .bottom)
                        }
                        .scrollContentBackground(.hidden)
                        .frame(maxHeight: .infinity)

                    }
                    
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
                            Image(systemName: "arrow.trianglehead.2.clockwise")
                                .resizable()
                                .frame(width: 33, height: 33)
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
                .sheet(isPresented: $showDistanceSheet) {
                    VStack(spacing: 16) {
                        Text("Choose Distance Limit")
                            .font(.system(size: 35))
                            .foregroundStyle(.gray)
                            .bold()

                        Picker("Distance", selection: $selectedDistance) {
                            ForEach(distanceOptions, id: \.self) { miles in
                                Text("\(miles) miles").tag(miles)
                                    .font(.system(size: 30))
                                    .foregroundStyle(.gray)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.wheel)
                        .frame(height: 200)

                        Button {
                            showDistanceSheet = false
                        } label : {
                            Text("Done")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .offset(y: 30)
                        }
                     
                    }
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity) // Let it expand
                    .background(Color.mainColor) // Set the background color
                    .presentationDetents([.fraction(0.6)]) // Limit sheet height to 50%
                }
                .sheet(isPresented: $showFoodSheet) {
                    VStack(spacing: 16) {
                        Text("Choose Food Type")
                            .font(.system(size: 35))
                            .foregroundStyle(.gray)
                            .bold()

                        Picker("Distance", selection: $selectedFoodType) {
                            ForEach(FoodType.allCases) { food in
                                Text(food.rawValue).tag(food)
                                    .font(.system(size: 30))
                                    .foregroundStyle(.gray)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.wheel)
                        .frame(height: 200)

                        Button {
                            showFoodSheet = false
                        } label : {
                            Text("Done")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .offset(y: 30)
                        }
                     
                    }
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity) // Let it expand
                    .background(Color.mainColor) // Set the background color
                    .presentationDetents([.fraction(0.6)]) // Limit sheet height to 50%
                }

            } // end of ZStack
        } // end of Navigation Stack
    } // end of body view
} // end of Profile view




#Preview {
    Shuffle_Screen()
}
