//
//  Favorites_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/1/25.
//
import FirebaseFirestore
import SwiftUI

struct Favorites_Screen: View {
    
    // Navigation Purposes, no need for Favorites_Screen
    @State private var toHome_Screen = false
    @State private var toList_Screen = false
    @State private var toShuffle_Screen = false
    @State private var toProfile_Screen = false
    
    @StateObject var faveViewModel = FavoritesScreenViewModel()
    
    // sample favorite items, for testing UI
    @FirestoreQuery var faveItems: [FavoriteItemModel]
    let userID: String
    init(userID: String) {
        self.userID = userID
        self._faveItems = FirestoreQuery(collectionPath: "Users/\(userID)/Sample Favorites")
    }
    // for testing and visual checks only
    /*let favoriteItems = [
           FavoriteItemModel(name: "Cava", location: "La Habra, CA"),
           FavoriteItemModel(name: "Chipotle", location: "Los Angeles, CA"),
           FavoriteItemModel(name: "In-N-Out", location: "Anaheim, CA")
       ]*/
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                VStack {
                    
                    HStack {
                        Text("Favorites")
                            .foregroundColor(.gray)
                            .font(.system(size: 40))
                            .fontWeight(.bold)
                            .offset(x: 30)
                        Spacer()
                        Image(systemName: "text.badge.plus")
                            .resizable()
                            .frame(width: 33, height: 33)
                            .foregroundStyle(.gray)
                            .offset(x: -30)
                    }
                    .offset(y: 20)
                    Divider()
                        .frame(height: 1)
                        .background(Color.gray)
                        .offset(y: 10)
                    
                    List(faveItems, id: \.ID) { item in
                        Favorite_Item(item: item)
                            .listRowInsets(EdgeInsets()) // Removes default List padding
                            .frame(maxWidth: .infinity) // Forces full width
                            .listRowSeparatorTint(.white, edges: .bottom)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Firestore.firestore()
                                    .collection("Users").document(userID)
                                    .collection("Sample Favorites").document(item.ID)
                                    .delete() { error in
                                        if let error = error {
                                            print("Error deleting document: \(error.localizedDescription)")
                                        } else {
                                            print("Item deleted successfully.")
                                        }
                                    }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .padding(.top, -20)
                    // .listStyle(.plain) // 🔹 Optional: Removes extra padding in grouped lists

                    
                    
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
        } // end of Navigation Stack
    } // end of body view
} // end of Profile view

#Preview {
    Favorites_Screen(userID: "7fnIEM2FyMY6LaTreBpAwGb3Jyg1")
}
