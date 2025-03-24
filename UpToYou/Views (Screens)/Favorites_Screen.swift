//
//  Favorites_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/1/25.
//
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

struct Favorites_Screen: View {
    
    // Navigation Purposes, no need for Favorites_Screen
    @State private var toHome_Screen = false
    @State private var toList_Screen = false
    @State private var toShuffle_Screen = false
    @State private var toProfile_Screen = false
    
    @StateObject var faveViewModel = FavoritesScreenViewModel()
    
    @FirestoreQuery var faveItems: [FavoriteItemModel]
    private var userID: String { // gets current user id
        Auth.auth().currentUser?.uid ?? "no-user"
    }
    init() { // firebase data gets stored into faveItems array
        // userID may not be initialized yet which is why it is not used in this query
        self._faveItems = FirestoreQuery(collectionPath: "Users/\(Auth.auth().currentUser?.uid ?? "no-user")/Favorite Restaurants")
    }
    
    @State private var showSearchSheet = false
    @State private var searchText = ""

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                VStack {
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("Favorites")
                                .foregroundColor(.gray)
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                                .offset(x: 30)
                            Spacer()
                            Button {
                                showSearchSheet = true
                            } label: {
                                Image(systemName: "text.badge.plus")
                                    .resizable()
                                    .frame(width: 33, height: 33)
                                    .foregroundStyle(.gray)
                            }
                            .offset(x: -30)
                            
                        }
                    
                        Divider()
                            .frame(height: 1)
                            .background(Color.gray)
                    }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.mainColor)
                    .zIndex(1)
                    
                
                    
                    List(faveItems, id: \.ID) { item in
                        Favorite_Item(item: item)
                            .listRowInsets(EdgeInsets()) // Removes default List padding
                            .frame(maxWidth: .infinity) // Forces full width
                            .listRowSeparatorTint(.white, edges: .bottom)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Firestore.firestore()
                                    .collection("Users").document(userID)
                                    .collection("Favorite Restaurants").document(item.ID)
                                    .delete() { error in
                                        if let error = error {
                                            print("Error deleting document: \(error.localizedDescription)")
                                        } else {
                                            print("Item deleted successfully.")
                                        }
                                    }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .zIndex(0) // keeps list items under the Favorites when scrolling
                    .offset(y: 2)
                    .padding(.top, -50)
                    .frame(maxHeight: .infinity) // ensure only list scrolls
                    //.listStyle(.plain) // Optional: Removes extra padding in grouped lists

                    
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
                            Image(systemName: "heart.fill")
                                .resizable()
                                .frame(width: 33, height: 33)
                            Text("Favorites")
                                .font(.caption)
                                .underline()
                                .bold()
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
                    .navigationDestination(isPresented: $toShuffle_Screen) {
                        Shuffle_Screen()
                            .navigationBarBackButtonHidden(true)
                    }
                    .navigationDestination(isPresented: $toProfile_Screen) {
                        Profile_Screen()
                            .navigationBarBackButtonHidden(true)
                    }
                    
                } // end of VStack
            } // end of ZStack
            .fullScreenCover(isPresented: $showSearchSheet) {
                // shows Restaurant_Search view when top right button is clicked
                Restaurant_Search(showSearchSheet: $showSearchSheet, searchText: $searchText)
            }
        } // end of Navigation Stack
    } // end of body view
} // end of Profile view



#Preview {
    Favorites_Screen()
}


