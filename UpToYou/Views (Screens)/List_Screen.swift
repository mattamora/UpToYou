//
//  List_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/1/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct List_Screen: View {
    
    @StateObject var ListViewModel = ListScreenViewModel()
    @State private var showCreateListSheet = false
    
    @State private var selectedList: CustomList? = nil
    @State private var showListSheet = false
    
    
    // for handling location
    //@StateObject private var locationManager = LocationManager()
    @ObservedObject private var locationManager = LocationManager.shared
    
    // Navigation Purposes, no need for List_Screen
    @State private var toHome_Screen = false
    @State private var toProfile_Screen = false
    @State private var toShuffle_Screen = false
    @State private var toFavorites_Screen = false
    
    // for swipe to delete a list
    private func deleteList(_ list: CustomList) {
        guard let userID = Auth.auth().currentUser?.uid, let listID = list.id else { return }

        Firestore.firestore()
            .collection("Users").document(userID)
            .collection("Lists").document(listID)
            .delete() { error in
                if let error = error {
                    print("Error deleting list: \(error.localizedDescription)")
                } else {
                    print("List deleted successfully.")
                    if let index = ListViewModel.userLists.firstIndex(where: { $0.id == list.id }) {
                        ListViewModel.userLists.remove(at: index)
                    }
                }
            }
    }
    
    var body: some View {

        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                VStack {
                    
                    // Lists, top of the screen, locked to top
                    VStack(spacing: 15) {
                        HStack {
                            Text("Lists")
                                .foregroundColor(.gray)
                                .font(.system(size: 40))
                                .fontWeight(.bold)
                                .offset(x: 30)
                            Spacer()
                            Button {
                                showCreateListSheet = true
                            } label: {
                                Image(systemName: "text.badge.plus")
                                    .resizable()
                                    .frame(width: 33, height: 33)
                                    .foregroundStyle(.gray)
                            }
                            .offset(x: -30)
                            
                        }
                       
                        Divider()
                            .frame(height: 2)
                            .background(Color.gray)
                    }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.mainColor)
                    .zIndex(1)
                    
                    
                    if ListViewModel.userLists.isEmpty {
                        Text("Add a List!")
                            .font(.title)
                            .foregroundColor(.gray)
                            .padding(.top, 50)
                    } else {
                        /*
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(ListViewModel.userLists) { list in
                                    ListItem(list: list, onChevronTap: {
                                        print("Tapped on list: \(list.name)") // DEBUG
                                        selectedList = list
                                        showListSheet = true
                                    })
                                    .padding(.horizontal)
                                    Divider()
                                        .frame(height: 0.5)
                                        .background(Color.gray)
                                }
                            }
                        } */
                        
                        // with swipe to delete
                        List {
                            ForEach(ListViewModel.userLists) { list in
                                ListItem(list: list, onChevronTap: {
                                    print("Tapped on list: \(list.name)") // DEBUG
                                    selectedList = list
                                    showListSheet = true
                                })
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteList(list)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .listRowInsets(EdgeInsets())
                                .background(Color.mainColor)
                                
                                Divider()
                                    .frame(height: 0.5)
                                    .background(Color.gray)
                            }
                           
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(PlainListStyle())

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
                    .navigationDestination(isPresented: $toHome_Screen) {
                        Home_Screen()
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
                    .navigationDestination(isPresented: $toFavorites_Screen) {
                        Favorites_Screen()
                            .navigationBarBackButtonHidden(true)
                    }
                    
                } // end of VStack
                .onAppear {
                    ListViewModel.fetchUserLists()
                }
            } // end of ZStack
            .fullScreenCover(isPresented: $showCreateListSheet, onDismiss: {
                ListViewModel.fetchUserLists() // Refresh lists after closing sheet
            }) {
                // shows CreateNewList view when top right button is clicked
                CreateListSheetView()
            }
            .fullScreenCover(item: $selectedList) { list in
                ListSheetView(ListSheetViewModel: ListSheetViewModel(list: list))
            }
        } // end of Navigation Stack
    } // end of body view
} // end of Profile view

#Preview {
    List_Screen()
}


// list item view
struct ListItem: View {
    let list: CustomList
    var onChevronTap: () -> Void // Callback when chevron is tapped
    
    var body: some View {
        HStack {
            // Placeholder for now
            Image("WhiteLogo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 90, height: 90)
                .cornerRadius(10)

            VStack(alignment: .leading) {
                Text(list.name)
                    .bold()
                    .font(.system(size: 25))
                    .foregroundColor(.white)
            }

            Spacer()

            Button {
                onChevronTap()
            } label: {
                Image(systemName: "chevron.up")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.mainColor)
        .cornerRadius(12)
    }
}

