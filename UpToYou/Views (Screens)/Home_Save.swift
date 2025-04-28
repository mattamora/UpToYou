//
//  Home_Save.swift
//  UpToYou
//
//  Created by Maria Lontok on 4/28/25.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Home_SaveView: View {
    @Environment(\.dismiss) var dismiss // To close the sheet
    @StateObject var Home_SaveViewModel = HomeSaveViewModel()
    let item: HomeItemModel
    
    @State private var selectedListIDs: Set<String> = [] // Track what’s selected
    
    let favoritesOption = ("Favorites", "favorites-id")

    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                
                Text("Add to")
                    .foregroundStyle(.gray)
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
        
                Divider()
                    .frame(height: 1)
                    .background(Color.gray)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach([favoritesOption] + Home_SaveViewModel.userLists.map { ($0.name, $0.id ?? "") }, id: \.1) { list in
                            HStack {
                                Text(list.0)
                                    .foregroundColor(.white)
                                    .font(.system(size: 22))
                                    .bold()
                                
                                Spacer()
                                
                                Button {
                                    toggleSelection(for: list.1)
                                } label: {
                                    Image(systemName: selectedListIDs.contains(list.1) ? "plus.circle.fill" : "plus.circle")
                                        .font(.system(size: 25))
                                        .foregroundColor(Color.themeColor)
                                }
                            }
                            .padding(.horizontal)
                        }

                    }
                    .padding(.top)
                }
                
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                            .padding()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Home_SaveViewModel.saveRestaurantToSelectedLists(item: item, selectedIDs: selectedListIDs) {
                                dismiss()
                            }
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundColor(.gray)
                            .font(.system(size: 20))
                            .padding()
                    }
                }
            }
            .background(Color.mainColor.ignoresSafeArea())
        
        }
    }
    
    // Toggle selection for plus.circle
    private func toggleSelection(for id: String) {
        if selectedListIDs.contains(id) {
            selectedListIDs.remove(id)
        } else {
            selectedListIDs.insert(id)
        }
    }
}

#Preview {
    Home_SaveView(item: HomeItemModel(
        ID: "sampleID",
        restoName: "Test Restaurant",
        picture: "https://via.placeholder.com/150",
        rating: 4.5,
        latitude: 37.7749,
        longitude: -122.4194,
        city: "San Francisco",
        state: "CA"
    ))
}
