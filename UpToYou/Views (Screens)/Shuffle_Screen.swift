//
//  Shuffle_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/1/25.
//


import SwiftUI
import MapKit
import FirebaseFirestore
import FirebaseAuth

struct Shuffle_Screen: View {
    
    @StateObject private var ShuffleViewModel = ShuffleScreenViewModel()
    @StateObject var List_ScreenViewModel = ListScreenViewModel()
    
    // Navigation Purposes, no need for Shuffle_Screen
    @State private var toHome_Screen = false
    @State private var toList_Screen = false
    @State private var toProfile_Screen = false
    @State private var toFavorites_Screen = false
    
    // Favorited items from Firebase
    @FirestoreQuery var faveItems: [FavoriteItemModel]
    private var userID: String {
        Auth.auth().currentUser?.uid ?? "no-user"
    }
    init() {
        self._faveItems = FirestoreQuery(collectionPath: "Users/\(Auth.auth().currentUser?.uid ?? "no-user")/Favorite Restaurants")
    }
    
    
    @State private var showShuffleSourceSheet = false
    @State private var selectedShuffleSource: String = "Favorites" // Default
    
    // variable for the selected random restaurant
    @State private var randomRestaurant: FavoriteItemModel? = nil
    
   
    // Animation variables
    @State private var rollingName: String = "" // the random restuarant names shuffled
    @State private var isRolling: Bool = false // if the names are still shuffling or not (visually)
    @State private var scale: CGFloat = 1.0
    @State private var offsetX: CGFloat = 300 // Start off-screen for slide in


    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Text("Up To You")
                        .foregroundColor(.gray)
                        .font(.system(size: 40))
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    
                    // filter for the shuffle
                    Button {
                        showShuffleSourceSheet = true
                    } label : {
                        HStack (spacing: 5) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text("Shuffle From: \(selectedShuffleSource)")
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        .foregroundColor(Color.gray)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }

                    
                    // shuffle button with an animation, bounce, roulette, slide-in
                    Button {
                        // Bounce Effect
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                            scale = 1.3
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.spring()) {
                                scale = 1.0
                            }
                        }

                        // Start Slot Machine Rolling
                        isRolling = true
                        rollingName = ""
                        offsetX = 300 // Reset for slide
                        randomRestaurant = nil // Clear previous selection

                        // Update shufflePool depending on selected source (Favorites or List)
                        ShuffleViewModel.updateShufflePool(from: selectedShuffleSource, lists: List_ScreenViewModel.userLists, favorites: faveItems) {

                            var rollCount = 0
                            let maxRolls = 40 // time length of roll
                            let rollInterval = 0.05 // how long each restaurant name shows up for

                            Timer.scheduledTimer(withTimeInterval: rollInterval, repeats: true) { timer in
                                rollCount += 1
                                if rollCount >= maxRolls {
                                    timer.invalidate()
                                    if let random = ShuffleViewModel.shufflePool.randomElement() {
                                        randomRestaurant = random
                                    }
                                    isRolling = false

                                    // Slide in after slot ends
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        offsetX = 0
                                    }
                                } else {
                                    rollingName = ShuffleViewModel.shufflePool.randomElement()?.restoName ?? ""
                                }
                            }

                        } // end of updateShufflePool completion

                    } label: {
                        HStack {
                            Image(systemName: "arrow.trianglehead.clockwise")
                                .font(.system(size: 24))
                            Text("Shuffle ")
                                .font(.system(size: 24))
                        }
                        .padding()
                        .frame(width: 300)
                        .background(Color.themeColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .scaleEffect(scale) // Bounce effect
                    }
                    
                    // display the random restaurant
                    if isRolling {
                        Text("Shuffling...")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                        Text(rollingName)
                            .font(.title)
                            .bold()
                            .foregroundColor(.gray)
                            .padding()
                    } else if let selected = randomRestaurant {
                        Text("You chose:")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                  
                         Favorite_Item(item: selected)
                             .padding(.horizontal)
                             .frame(height: 90)
                             .offset(x: offsetX) // Slide-in effect
                             .animation(.easeOut, value: offsetX)
                             .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(style: StrokeStyle(lineWidth: 2))
                                    .foregroundColor(Color.gray)
                             )
                             .padding(.horizontal)
                    } else {
                        Text("Tap Shuffle to get a suggestion")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                            .padding()
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
                .sheet(isPresented: $showShuffleSourceSheet) {
                    VStack(spacing: 16) {
                        Text("Choose Shuffle Source")
                            .font(.system(size: 27))
                            .foregroundStyle(.gray)
                            .bold()
                        
                        Picker("Shuffle From", selection: $selectedShuffleSource) {
                            Text("Favorites").tag("Favorites")
                                .foregroundStyle(.gray)
                            ForEach(List_ScreenViewModel.userLists, id: \.id) { list in
                                Text(list.name).tag(list.name)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .labelsHidden()
                        .pickerStyle(.wheel)
                        .frame(height: 200)

                        Button {
                            showShuffleSourceSheet = false
                        } label : {
                            Text("Done")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.gray)
                                .overlay(
                                   RoundedRectangle(cornerRadius: 12)
                                       .stroke(style: StrokeStyle(lineWidth: 2))
                                       .foregroundColor(Color.gray)
                                )
                                .offset(y: 30)
                        }
                        
                    }
                    .padding(.horizontal)
                    .frame(maxHeight: .infinity)
                    .background(Color.mainColor)
                    .presentationDetents([.fraction(0.5)])
                }
                .onAppear {
                    print("Fetched Lists: \(List_ScreenViewModel.userLists.map { $0.name })")
                    List_ScreenViewModel.fetchUserLists()
                }


            } // end of ZStack
        } // end of Navigation Stack
    } // end of body view
    
} // end of Profile view




#Preview {
    Shuffle_Screen()
}











