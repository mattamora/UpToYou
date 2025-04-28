//
//  Home_Item.swift
//  UpToYou
//
//  Created by Maria Lontok on 4/26/25.
//

import SwiftUI

struct Home_Item: View {
    
    // shows Home_Save
    @State private var showSaveSheet = false
    
    // uses/creates the struct of HomeItemModel
    let item: HomeItemModel
    
    var body: some View {
        ZStack {
            VStack (spacing: 4) {
                
                // Load restaurant image
                AsyncImage(url: URL(string: item.picture)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 260, height: 160)
                .cornerRadius(10)
                .clipped()
                
                // Restaurant name + list button
                HStack() {
                    Text(item.restoName)
                        .bold()
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    Button {
                        showSaveSheet = true
                    } label: {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                    }
                    .fullScreenCover(isPresented: $showSaveSheet) {
                        Home_SaveView(item: item)
                    }
                }
                .frame(width: 260)
                .padding([.top, .horizontal], 7)
                
                // Star rating
                StarRatingView(rating: item.rating)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // City + State as clickable link
                Button {
                    openInMaps(latitude: item.latitude, longitude: item.longitude)
                } label: {
                    Text("\(item.city), \(item.state)")
                        .underline()
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(width: 260)
        }
    } // end of body View
    
    // Open Apple Maps to restaurant location
    func openInMaps(latitude: Double, longitude: Double) {
        let urlString = "http://maps.apple.com/?daddr=\(latitude),\(longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
} // end of Home_Item struct View

#Preview {
    Home_Item(item: HomeItemModel(
        ID: "testID",
        restoName: "Cava",
        picture: "CAVA",
        rating: 2.5,
        latitude: 33.915436,
        longitude: -117.968712,
        city: "La Habra",
        state: "CA"
    ))
}
