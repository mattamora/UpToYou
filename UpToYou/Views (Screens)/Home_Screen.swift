//
//  Home_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 2/28/25.
//
/*
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

public struct Home_Screen: View {
    @StateObject var HomeViewModel = HomeScreenViewModel()
    // @StateObject var locationManager = LocationManager() // For user location
    @ObservedObject private var locationManager = LocationManager.shared
    
    // Section variables, trending, rated, on a budget, todays pick
    @State private var trendingRestaurants: [Restaurant] = []
    @State private var isLoadingTrending = true
    @State private var highlyRatedRestaurants: [Restaurant] = []
    @State private var isLoadingHighlyRated = true
    @State private var budgetRestaurants: [Restaurant] = []
    @State private var isLoadingBudget = true
    @FirestoreQuery var faveItems: [FavoriteItemModel] // todays top pick
    init() {
        let userID = Auth.auth().currentUser?.uid ?? "no-user"
        self._faveItems = FirestoreQuery(collectionPath: "Users/\(userID)/Favorite Restaurants")
    }
    
    // to fix issue of constant refreshing
    @State private var trendingFetched = false
    @State private var highlyRatedFetched = false
    @State private var budgetFetched = false
    
    
    // Navigation Purposes, no need for Home_Screen variable
    @State private var toList_Screen = false
    @State private var toProfile_Screen = false
    @State private var toShuffle_Screen = false
    @State private var toFavorites_Screen = false
    @State private var showProfileScreen = false
    
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                VStack {
                    
                    // Welcome user, top of the screen, locked to top
                    VStack(spacing: 15) {
                        if let _ = HomeViewModel.currentUser {
                            Text("Welcome, \(HomeViewModel.userFirstName)!")
                                .foregroundColor(.gray)
                                .font(.system(size: 30))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .offset(x: 15)
                        } else {
                            Text("Welcome!")
                                .foregroundColor(.gray)
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .offset(x: 15)
                        }
                       
                        Divider()
                            .frame(height: 2)
                            .background(Color.gray)
                            //.padding(.bottom, 20)
                    }
                    .onAppear { HomeViewModel.fetchUser() }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.mainColor)
                    .zIndex(1)
                    
                    // for shuffle or home screen? UI idea
                    // Text("What are you in the mood for?")
                    // then put a search bar

                    
                    
                    // Scrollable content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
    
                            // Trending nearby restaurants
                            VStack(alignment: .leading) {
                                
                                Text("Trending nearby")
                                    .font(.system(size: 25))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                if isLoadingTrending {
                                    ProgressView("Loading nearby restaurants...")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else if trendingRestaurants.isEmpty {
                                    Text("No trending restaurants found.")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(trendingRestaurants, id: \.id) { item in
                                                let homeItem = HomeItemModel(
                                                    ID: item.id,
                                                    restoName: item.name,
                                                    picture: item.image_url ?? "",
                                                    rating: item.rating,
                                                    latitude: item.coordinates.latitude,
                                                    longitude: item.coordinates.longitude
                                                )
                                                Home_Item(item: homeItem)
                                            }
                                        }
                                        .padding(.horizontal)
                                        //.frame(height: 280)
                                    }
                                }
                            }
                            .onChange(of: locationManager.userLocation?.latitude) { _ in
                                if let location = locationManager.userLocation, !trendingFetched {
                                    trendingFetched = true
                                    isLoadingTrending = true
                                    HomeViewModel.fetchTrendingRestaurants(latitude: location.latitude, longitude: location.longitude) { restos in
                                        trendingRestaurants = restos
                                        isLoadingTrending = false
                                    }
                                }
                            }
                            
                            // Highly Rated Restaurants
                            VStack(alignment: .leading) {
                                Divider()
                                    .frame(height: 0.5)
                                    .background(Color.gray)
                                    .padding(.top)

                                Text("Highly Rated")
                                    .font(.system(size: 25))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                if isLoadingHighlyRated {
                                    ProgressView("Loading highly rated spots...")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else if highlyRatedRestaurants.isEmpty {
                                    Text("No highly rated restaurants found.")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(highlyRatedRestaurants, id: \.id) { item in
                                                let homeItem = HomeItemModel(
                                                    ID: item.id,
                                                    restoName: item.name,
                                                    picture: item.image_url ?? "",
                                                    rating: item.rating,
                                                    latitude: item.coordinates.latitude,
                                                    longitude: item.coordinates.longitude
                                                )
                                                Home_Item(item: homeItem)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            /* .onAppear {
                                if let location = locationManager.userLocation, !hasFetchedRated {
                                    hasFetchedRated = true
                                    isLoadingHighlyRated = true
                                    HomeViewModel.fetchHighlyRatedRestaurants(latitude: location.latitude, longitude: location.longitude) { restos in
                                        highlyRatedRestaurants = restos
                                        isLoadingHighlyRated = false
                                    }
                                }
                            } */
                            .onChange(of: locationManager.userLocation?.latitude) { _ in
                                if let location = locationManager.userLocation, !highlyRatedFetched {
                                    highlyRatedFetched = true
                                    isLoadingHighlyRated = true
                                    HomeViewModel.fetchHighlyRatedRestaurants(latitude: location.latitude, longitude: location.longitude) { restos in
                                        highlyRatedRestaurants = restos
                                        isLoadingHighlyRated = false
                                    }
                                }
                            }

                            
                            // On a budget restaurants
                            VStack(alignment: .leading) {
                                Divider()
                                    .frame(height: 0.5)
                                    .background(Color.gray)
                                    .padding(.top)

                                Text("On a budget")
                                    .font(.system(size: 25))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                if isLoadingBudget {
                                    ProgressView("Finding affordable spots...")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else if budgetRestaurants.isEmpty {
                                    Text("No budget-friendly restaurants found.")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(budgetRestaurants, id: \.id) { item in
                                                let homeItem = HomeItemModel(
                                                    ID: item.id,
                                                    restoName: item.name,
                                                    picture: item.image_url ?? "",
                                                    rating: item.rating,
                                                    latitude: item.coordinates.latitude,
                                                    longitude: item.coordinates.longitude
                                                )
                                                Home_Item(item: homeItem)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .onAppear {
                                if let location = locationManager.userLocation, !budgetFetched {
                                    budgetFetched = true
                                    isLoadingBudget = true
                                    HomeViewModel.fetchBudgetRestaurants(latitude: location.latitude, longitude: location.longitude) { restos in
                                        budgetRestaurants = restos
                                        isLoadingBudget = false
                                    }
                                }
                            }
                           

                            
                            // Today’s Pick Section
                            VStack(alignment: .leading) {
                                Divider()
                                    .frame(height: 0.5)
                                    .background(Color.gray)
                                    .padding(.top)

                                Text("Today’s pick!")
                                    .font(.system(size: 25))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                if let pick = HomeViewModel.todaysPick {
                                    let homeItem = HomeItemModel(
                                        ID: pick.ID,
                                        restoName: pick.restoName,
                                        picture: pick.picture,
                                        rating: pick.rating,
                                        latitude: pick.latitude,
                                        longitude: pick.longitude
                                    )
                                    Home_Item(item: homeItem)
                                        .padding(.horizontal)
                                } else {
                                    Text("No favorites to pick from yet.")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                            }
                            .onChange(of: faveItems) { newFavorites in
                                if !newFavorites.isEmpty && HomeViewModel.todaysPick == nil {
                                    HomeViewModel.loadTodaysPick(from: newFavorites)
                                }
                            }

                        }
                        .padding(.bottom, 60) // Leave room for bottom nav
                    
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
                    .navigationDestination(isPresented: $toShuffle_Screen) {
                        Shuffle_Screen()
                            .navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $toFavorites_Screen) {
                        Favorites_Screen()
                            .navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $toProfile_Screen) {
                        Profile_Screen()
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

*/


import SwiftUI
import FirebaseAuth
import FirebaseFirestore

public struct Home_Screen: View {
    @StateObject var HomeViewModel = HomeScreenViewModel()
    @ObservedObject private var locationManager = LocationManager.shared
    
    @State private var trendingRestaurants: [Restaurant] = []
    @State private var isLoadingTrending = true
    @State private var highlyRatedRestaurants: [Restaurant] = []
    @State private var isLoadingHighlyRated = true
    @State private var budgetRestaurants: [Restaurant] = []
    @State private var isLoadingBudget = true
    
    @FirestoreQuery var faveItems: [FavoriteItemModel]
    init() {
        let userID = Auth.auth().currentUser?.uid ?? "no-user"
        self._faveItems = FirestoreQuery(collectionPath: "Users/\(userID)/Favorite Restaurants")
    }
    
    @State private var trendingFetched = false
    @State private var highlyRatedFetched = false
    @State private var budgetFetched = false
    
    @State private var toList_Screen = false
    @State private var toProfile_Screen = false
    @State private var toShuffle_Screen = false
    @State private var toFavorites_Screen = false
    @State private var showProfileScreen = false
    
    public var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                VStack {
                    VStack(spacing: 15) {
                        if let _ = HomeViewModel.currentUser {
                            Text("Welcome, \(HomeViewModel.userFirstName)!")
                                .foregroundColor(.gray)
                                .font(.system(size: 30))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .offset(x: 15)
                        } else {
                            Text("Welcome!")
                                .foregroundColor(.gray)
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .offset(x: 15)
                        }
                        Divider()
                            .frame(height: 2)
                            .background(Color.gray)
                    }
                    .onAppear { HomeViewModel.fetchUser() }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.mainColor)
                    .zIndex(1)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Trending nearby restaurants
                            VStack(alignment: .leading) {
                                Text("Trending nearby")
                                    .font(.system(size: 25))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                
                                if isLoadingTrending {
                                    ProgressView("Loading nearby restaurants...")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else if trendingRestaurants.isEmpty {
                                    Text("No trending restaurants found.")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(trendingRestaurants, id: \.id) { item in
                                                let id = item.id
                                                let name = item.name
                                                let picture = item.image_url ?? ""
                                                let rating = item.rating
                                                let lat = item.coordinates.latitude
                                                let lon = item.coordinates.longitude
                                                let city = item.location.city
                                                let state = item.location.state

                                                let homeItem = HomeItemModel(
                                                    ID: id,
                                                    restoName: name,
                                                    picture: picture,
                                                    rating: rating,
                                                    latitude: lat,
                                                    longitude: lon,
                                                    city: city,
                                                    state: state
                                                )
                                                Home_Item(item: homeItem)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .onChange(of: locationManager.userLocation?.latitude) { _ in
                                if let location = locationManager.userLocation, !trendingFetched {
                                    trendingFetched = true
                                    isLoadingTrending = true
                                    HomeViewModel.fetchTrendingRestaurants(latitude: location.latitude, longitude: location.longitude) { restos in
                                        trendingRestaurants = restos
                                        isLoadingTrending = false
                                    }
                                }
                            }
                            
                            // Highly Rated Restaurants
                            VStack(alignment: .leading) {
                                Divider()
                                    .frame(height: 0.5)
                                    .background(Color.gray)
                                    .padding(.top)

                                Text("Highly Rated")
                                    .font(.system(size: 25))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                if isLoadingHighlyRated {
                                    ProgressView("Loading highly rated spots...")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else if highlyRatedRestaurants.isEmpty {
                                    Text("No highly rated restaurants found.")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(highlyRatedRestaurants, id: \.id) { item in
                                                let id = item.id
                                                let name = item.name
                                                let picture = item.image_url ?? ""
                                                let rating = item.rating
                                                let lat = item.coordinates.latitude
                                                let lon = item.coordinates.longitude
                                                let city = item.location.city
                                                let state = item.location.state

                                                let homeItem = HomeItemModel(
                                                    ID: id,
                                                    restoName: name,
                                                    picture: picture,
                                                    rating: rating,
                                                    latitude: lat,
                                                    longitude: lon,
                                                    city: city,
                                                    state: state
                                                )
                                                Home_Item(item: homeItem)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .onChange(of: locationManager.userLocation?.latitude) { _ in
                                if let location = locationManager.userLocation, !highlyRatedFetched {
                                    highlyRatedFetched = true
                                    isLoadingHighlyRated = true
                                    HomeViewModel.fetchHighlyRatedRestaurants(latitude: location.latitude, longitude: location.longitude) { restos in
                                        highlyRatedRestaurants = restos
                                        isLoadingHighlyRated = false
                                    }
                                }
                            }

                            // On a budget restaurants
                            VStack(alignment: .leading) {
                                Divider()
                                    .frame(height: 0.5)
                                    .background(Color.gray)
                                    .padding(.top)

                                Text("On a budget")
                                    .font(.system(size: 25))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                if isLoadingBudget {
                                    ProgressView("Finding affordable spots...")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else if budgetRestaurants.isEmpty {
                                    Text("No budget-friendly restaurants found.")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            ForEach(budgetRestaurants, id: \.id) { item in
                                                let id = item.id
                                                let name = item.name
                                                let picture = item.image_url ?? ""
                                                let rating = item.rating
                                                let lat = item.coordinates.latitude
                                                let lon = item.coordinates.longitude
                                                let city = item.location.city
                                                let state = item.location.state

                                                let homeItem = HomeItemModel(
                                                    ID: id,
                                                    restoName: name,
                                                    picture: picture,
                                                    rating: rating,
                                                    latitude: lat,
                                                    longitude: lon,
                                                    city: city,
                                                    state: state
                                                )
                                                Home_Item(item: homeItem)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .onAppear {
                                if let location = locationManager.userLocation, !budgetFetched {
                                    budgetFetched = true
                                    isLoadingBudget = true
                                    HomeViewModel.fetchBudgetRestaurants(latitude: location.latitude, longitude: location.longitude) { restos in
                                        budgetRestaurants = restos
                                        isLoadingBudget = false
                                    }
                                }
                            }

                            // Today’s Pick Section
                            VStack(alignment: .leading) {
                                Divider()
                                    .frame(height: 0.5)
                                    .background(Color.gray)
                                    .padding(.top)

                                Text("Today’s pick!")
                                    .font(.system(size: 25))
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                if let pick = HomeViewModel.todaysPick {
                                    let homeItem = HomeItemModel(
                                        ID: pick.ID,
                                        restoName: pick.restoName,
                                        picture: pick.picture,
                                        rating: pick.rating,
                                        latitude: pick.latitude,
                                        longitude: pick.longitude,
                                        city: "Unknown",
                                        state: "Unknown"
                                    )
                                    Home_Item(item: homeItem)
                                        .padding(.horizontal)
                                } else {
                                    Text("No favorites to pick from yet.")
                                        .foregroundColor(.gray)
                                        .padding()
                                }
                            }
                            .onChange(of: faveItems) { newFavorites in
                                if !newFavorites.isEmpty && HomeViewModel.todaysPick == nil {
                                    HomeViewModel.loadTodaysPick(from: newFavorites)
                                }
                            }

                        }
                        .padding(.bottom, 60)
                    }

                    // Bottom navigation icons (unchanged)
                    Spacer()
                    Divider()
                        .frame(height: 2)
                        .background(Color.gray)
                        .padding(.bottom, 20)
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
                                .onTapGesture { toList_Screen = true }
                            Text("List")
                                .font(.caption)
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "shuffle.circle")
                                .resizable()
                                .frame(width: 37, height: 37)
                                .onTapGesture { toShuffle_Screen = true }
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
                                .onTapGesture { toProfile_Screen = true }
                            Text("Profile")
                                .font(.caption)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 20)
                    .foregroundColor(.gray)
                    .navigationDestination(isPresented: $toList_Screen) {
                        List_Screen().navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $toShuffle_Screen) {
                        Shuffle_Screen().navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $toFavorites_Screen) {
                        Favorites_Screen().navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $toProfile_Screen) {
                        Profile_Screen().navigationBarBackButtonHidden(true)
                    }
                }
            }
        }
    }
}

#Preview {
    Home_Screen()
}
