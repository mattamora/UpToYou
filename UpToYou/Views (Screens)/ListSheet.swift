//
//  Each_List.swift
//  UpToYou
//
//  Created by Maria Lontok on 4/27/25.
//


import SwiftUI


import SwiftUI

struct ListSheetView: View {
    @ObservedObject var ListSheetViewModel: ListSheetViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            // x icon and edit icon, closes the popup screen and edits the list
            HStack {
                Button{
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .font(.system(size: 30))
                        .padding()
                }

                Spacer()
                Button{
                  // edit list icon, will do later
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                        .font(.system(size: 30))
                        .padding()
                }
            }
            .padding(.top, 30)

            if let imageURL = ListSheetViewModel.list.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 280, height: 280)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white, lineWidth: 1)
                )
            } else {
                Image("WhiteLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 280, height: 280)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
            }


            // Dynamic List Name
            Text(ListSheetViewModel.list.name)
                .foregroundStyle(.gray)
                .font(.system(size: 30))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            // Dynamic Created Date
            Text("Created on: \(ListSheetViewModel.formattedDate)")
                .foregroundStyle(.gray)
                .font(.system(size: 10))

            Divider()
                .frame(height: 0.5)
                .background(Color.gray)
                .opacity(0.5)

            // Display fetched restaurants
            if ListSheetViewModel.favoriteItems.isEmpty {
                Text("No Restaurants in this List")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(ListSheetViewModel.favoriteItems, id: \.ID) { item in
                    Favorite_Item(item: item)
                        .listRowInsets(EdgeInsets())
                        .frame(maxWidth: .infinity)
                        .listRowSeparatorTint(.white, edges: .bottom)
                }
                .scrollContentBackground(.hidden)
                .zIndex(0)
                .offset(y: 2)
            }

            Spacer()
        } // end of VStack
        .padding()
        .background(Color.mainColor)
        .ignoresSafeArea()
    }
}

#Preview {
    ListSheetView(ListSheetViewModel: ListSheetViewModel(list: CustomList(
        id: "1",
        name: "Sample List",
        restaurantIDs: ["1", "2"],
        createdDate: Date()
    )))
}
