//
//  Restaurant_Search.swift
//  UpToYou
//
//  Created by Maria Lontok on 3/22/25.
//
// this is a popup screen used in Favorites_Screen

import SwiftUI
import MapKit

struct Restaurant_Search: View {
   
    var mode: RestaurantSearchMode = .favorites // Default is favorites
        
    @StateObject var searchViewModel = RestaurantSearchViewModel()
    
    // for handling location, viewing current location
    //@StateObject private var locationManager = LocationManager()
    @ObservedObject private var locationManager = LocationManager.shared

    @Binding var showSearchSheet: Bool
    @Binding var searchText: String  // the text typed in the search bar

    // For listAdd mode – track selected restaurants locally
    @State private var selectedRestaurantIDs: Set<String> = []
    @State private var selectedRestaurants: [Restaurant] = []
    
    var existingSelectedRestaurantIDs: Set<String> = []

    // Add this optional callback to pass selected restaurants back
    var onRestaurantsSelected: (([Restaurant]) -> Void)? = nil
    
    func toggleRestaurantSelection(_ restaurant: Restaurant) {
        if selectedRestaurantIDs.contains(restaurant.id) {
            selectedRestaurantIDs.remove(restaurant.id)
            selectedRestaurants.removeAll { $0.id == restaurant.id }
        } else {
            selectedRestaurantIDs.insert(restaurant.id)
            selectedRestaurants.append(restaurant)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // x icon, closes the popup screen
            HStack {
                Button{
                    showSearchSheet = false // Dismiss the screen
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 30))
                        .padding()
                }

                Spacer()
                
            }
            .padding(.top, 30)

            Text("Search Restaurants")
                .font(.system(size: 30))
                .foregroundColor(.gray)
                .padding(.top, -10)
                .bold()

            // search bar UI, only shows 10 restaurants 
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)

                TextField("Restaurant Name", text: $searchText)
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
            .frame(width: 350, height: 40)
            .background(Color.white)
            .cornerRadius(10)
            .padding()


            if searchViewModel.results.isEmpty {
                Text(searchText.isEmpty ? "Results will appear here..." : "No valid result within 25 miles...")
                    .foregroundColor(.gray)
                    .padding(.top, 50)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(searchViewModel.results, id: \.id) { r in
                            SearchResultItem(
                                searchViewModel: searchViewModel,
                                restaurant: r,
                                mode: mode,
                                selectedRestaurantIDs: $selectedRestaurantIDs,
                                toggleSelection: toggleRestaurantSelection
                            )
                        }
                    }
                    .padding(.top)
                }
            }


            Spacer()
        } // end of VStack
        .padding()
        .background(Color.mainColor)
        .ignoresSafeArea()
        .onChange(of: searchText) { newText in  // shows restaurants as the user types
            if let location = locationManager.userLocation {
                searchViewModel.searchYelp(for: newText,
                                           latitude: location.latitude,
                                           longitude: location.longitude)
            }
        }
        .onAppear {
            searchViewModel.loadFavorites()
            selectedRestaurantIDs = existingSelectedRestaurantIDs
        }
        .onDisappear {
            if mode == .listAdd {
                onRestaurantsSelected?(selectedRestaurants)
            }
        }
    } // end of body view
}


// view item for the search results, separate for efficiency, better for compilation
// goes inside ScrollView
struct SearchResultItem: View {
    @ObservedObject var searchViewModel: RestaurantSearchViewModel
    let restaurant: Restaurant
    let mode: RestaurantSearchMode
    
    @Binding var selectedRestaurantIDs: Set<String> // for listAdd
    var toggleSelection: (Restaurant) -> Void       // function to toggle selection
    
    var body: some View {
        HStack {
            // Image
            AsyncImage(url: URL(string: restaurant.image_url ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 70, height: 70)
            .cornerRadius(10)
            .clipped()

            // Info
            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .bold()
                    .font(.system(size: 25))
                    .foregroundColor(.white)
                    .offset(y: 8)

                StarRatingView(rating: restaurant.rating)
                    .offset(y: -7)

                Text("\(restaurant.location.address1 ?? ""), \(restaurant.location.city), \(restaurant.location.state)")
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .offset(y: -7)
            }

            Spacer()

            // Icon Logic Based on Mode
            if mode == .favorites {
                Image(systemName: searchViewModel.favoriteIDs.contains(restaurant.id) ? "heart.fill" : "heart")
                    .font(.system(size: 30))
                    .foregroundColor(searchViewModel.favoriteIDs.contains(restaurant.id) ? .themeColor : .white)
                    .onTapGesture {
                        if !searchViewModel.favoriteIDs.contains(restaurant.id) {
                            withAnimation {
                                searchViewModel.addToFavorites(restaurant: restaurant)
                            }
                        }
                    }
            } else if mode == .listAdd {
                Image(systemName: selectedRestaurantIDs.contains(restaurant.id) ? "plus.circle.fill" : "plus.circle")
                    .font(.system(size: 30))
                    .foregroundColor(.themeColor)
                    .onTapGesture {
                        toggleSelection(restaurant)
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .padding([.top, .bottom], 15)
        .background(Color.mainColor)
        .cornerRadius(12)
    }
}





#Preview {
    Restaurant_Search(showSearchSheet: .constant(true),
                      searchText: .constant("Sample Restaurant Name"))
}
