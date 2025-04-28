//
//  AddNewList.swift
//  UpToYou
//
//  Created by Maria Lontok on 4/27/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateListSheetView: View {
    @Environment(\.dismiss) var dismiss // To close the sheet
    @StateObject var viewModel = CreateListViewModel()
    
    // Converts selected restaurants to displayable FavoriteItemModels
    var favoriteItemModels: [FavoriteItemModel] {
        viewModel.selectedRestaurants.map { restaurant in
            FavoriteItemModel(
                ID: restaurant.id,
                restoName: restaurant.name,
                location: "\(restaurant.location.city), \(restaurant.location.state)",
                picture: restaurant.image_url ?? "",
                rating: restaurant.rating,
                latitude: restaurant.coordinates.latitude,
                longitude: restaurant.coordinates.longitude
            )
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // List Image Placeholder with Camera Icon
                ZStack {
                    if let selectedImage = viewModel.selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 280, height: 280)
                            .clipped()
                            .cornerRadius(10)
                    } else {
                        Image("WhiteLogo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 280, height: 280)
                            .opacity(0.2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                    }

                    Button {
                        viewModel.showImagePicker = true
                    } label: {
                        Image(systemName: "camera.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.5)).frame(width: 60, height: 60))
                    }
                }

                // List Title
                TextField("List Title", text: $viewModel.listTitle)
                    .foregroundStyle(.gray)
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Divider()
                    .frame(height: 0.5)
                    .background(Color.gray)
                    .opacity(0.5)

                // Add Restaurant Button
                Button {
                    viewModel.showRestaurantSearchSheet = true
                } label: {
                    HStack {
                        Image(systemName: "text.badge.plus")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.gray)
                        Text("Add Restaurant")
                            .foregroundStyle(.gray)
                    }
                    .font(.title3)
                }
                Divider()
                    .frame(height: 0.5)
                    .background(Color.gray)
                    .opacity(0.5)

                // Display Selected Restaurants
                List(favoriteItemModels, id: \.ID) { item in
                    Favorite_Item(item: item)
                        .listRowInsets(EdgeInsets())
                        .frame(maxWidth: .infinity)
                        .listRowSeparatorTint(.white, edges: .bottom)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                viewModel.selectedRestaurants.removeAll { $0.id == item.ID }
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                }
                .scrollContentBackground(.hidden)
                .zIndex(0)
                .offset(y: 2)
                .frame(maxHeight: .infinity)

                Spacer()
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
                        if viewModel.listTitle.trimmingCharacters(in: .whitespaces).isEmpty {
                            viewModel.showErrorAlert = true
                        } else {
                            viewModel.saveListToFirebase()
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
            .fullScreenCover(isPresented: $viewModel.showImagePicker) {
                ImagePicker(image: $viewModel.selectedImage)
            }
            .fullScreenCover(isPresented: $viewModel.showRestaurantSearchSheet) {
                Restaurant_Search(
                    mode: .listAdd,
                    showSearchSheet: $viewModel.showRestaurantSearchSheet,
                    searchText: $viewModel.searchText,
                    existingSelectedRestaurantIDs: Set(viewModel.selectedRestaurants.map { $0.id }),
                    onRestaurantsSelected: { selected in
                        selected.forEach { newRestaurant in
                            if !viewModel.selectedRestaurants.contains(where: { $0.id == newRestaurant.id }) {
                                viewModel.selectedRestaurants.append(newRestaurant)
                            }
                        }
                    }
                )
            }
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text("List Title is Empty"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

#Preview {
    CreateListSheetView()
}
