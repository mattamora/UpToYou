//
//  Favorite_Item.swift
//  UpToYou
//
//  Created by Maria Lontok on 3/18/25.
//

import SwiftUI

struct Favorite_Item: View {
    
    // uses/creates the struct of FavoriteItemModel
    let item: FavoriteItemModel
    
    var body: some View {
        ZStack {
            Color.mainColor.ignoresSafeArea()
            HStack {
                
                //  load an image from a URL over the internet
                // URL(string: ...) converts that string into a proper URL object, what AsyncImage needs to make the web request, If this string is invalid (like not a real URL), AsyncImage just shows nothing
                AsyncImage(url: URL(string: item.picture)) { image in
                    image
                        .resizable()
                        .scaledToFill() // fills frame, crops if needed
                } placeholder: {
                    // shows while the image is still loading
                    // spinning loading circle (standard iOS style)
                    // goes away automatically when the image finishes loading
                    ProgressView()
                }
                //.aspectRatio(contentMode: .fit)
                .frame(width: 70, height: 70)
                .cornerRadius(10)
                .clipped() // ensures cropped edges don't overflow
                    

                VStack(alignment: .leading) {
                    Text(item.restoName) // ← Dynamic name
                        .bold()
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                        .offset(y: 8)

                    StarRatingView(rating: item.rating)
                        .offset(y: -7)
                     
                    Text(item.location) // ← Dynamic location
                        .font(.system(size: 10))
                        .offset(y: -7)
                        .foregroundColor(.white)
                }
                

                Spacer()

                Button {
                    openInMaps(latitude: item.latitude, longitude: item.longitude)
                } label: {
                    Image(systemName: "arrow.up.forward.app")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }

            } // end of HStack
            .frame(maxWidth: .infinity) //  Expands row fully
            .padding([.top, .bottom], 15) //  Adds padding for spacing
        }
    } // end of body View
    
    // takes user to apple maps with specific directions
    func openInMaps(latitude: Double, longitude: Double) {
        let urlString = "http://maps.apple.com/?daddr=\(latitude),\(longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
} // end of Favorite_Item struct View

#Preview {
    // passing in test arguments
    Favorite_Item(item: FavoriteItemModel(
        ID: "testID",
        restoName: "Cava",
        location: "La Habra, CA",
        picture: "CAVA",
        rating: 2.5,
        latitude: 33.915436,
        longitude: -117.968712
    ))
}
