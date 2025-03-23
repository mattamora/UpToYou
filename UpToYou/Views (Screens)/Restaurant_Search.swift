//
//  Restaurant_Search.swift
//  UpToYou
//
//  Created by Maria Lontok on 3/22/25.
//
// this is a popup screen used in Favorites_Screen

import SwiftUI

struct Restaurant_Search: View {
    @Binding var showSearchSheet: Bool
    @Binding var searchText: String  // the text typed in the search bar

    var body: some View {
        VStack(spacing: 0) {
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

            Text("Search Restaurants")
                .font(.system(size: 30))
                .foregroundColor(.gray)
                .padding(.top, -10)
                .bold()

            TextField("Restaurant Name", text: $searchText)
                .padding(.horizontal)
                .frame(width: 350, height: 40)
                .background(Color.white)
                .cornerRadius(10)
                .padding()
                

            ScrollView {
                Text("Results will appear here...")
                    .foregroundColor(.gray)
                    .padding(.top, 50)
            }

            Spacer()
        }
        .padding()
        .background(Color.mainColor)
        .ignoresSafeArea()
    }
}

#Preview {
    Restaurant_Search(showSearchSheet: .constant(true),
                      searchText: .constant("Sample Restaurant Name"))
}
