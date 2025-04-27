//
//  Home_Item.swift
//  UpToYou
//
//  Created by Maria Lontok on 4/26/25.
//

import SwiftUI
import CoreLocation


struct Home_Item: View {
    
    @StateObject private var locationManager = LocationManager() // get user's location

    // Calculate distance from user to restaurant
    private var distanceText: String {
        guard let userLocation = locationManager.userLocation else {
            return "Locating..."
        }

        let restaurantLocation = CLLocation(latitude: item.latitude, longitude: item.longitude)
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)

        let distanceInMeters = userCLLocation.distance(from: restaurantLocation)
        let distanceInMiles = distanceInMeters / 1609.34

        return String(format: "%.1f miles", distanceInMiles)
    }

    
    // uses/creates the struct of HomeItemModel
    let item: HomeItemModel
    
    var body: some View {
        ZStack {
            VStack (spacing: 4) {
                
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
                .frame(width: 260, height: 160)
                .cornerRadius(10)
                .clipped() // ensures cropped edges don't overflow
                    

                HStack() {
                    Text(item.restoName)
                        .bold()
                        .font(.system(size: 25))
                        .foregroundColor(.white)
                        .lineLimit(1) // Keep on one line
                        .minimumScaleFactor(0.5) // Shrinks the text if it's too long, max shrinkage is half
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 260)
                .padding([.top, .horizontal], 7)
                
                StarRatingView(rating: item.rating)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                
                // distance as clickable Apple Maps link
                Button {
                    openInMaps(latitude: item.latitude, longitude: item.longitude)
                } label : {
                    Text(distanceText)
                        .underline()
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            

            } // end of HStack
            .frame(width: 260) // or whatever size matches the image
        }
    } // end of body View
    
    // takes user to apple maps with specific directions
    func openInMaps(latitude: Double, longitude: Double) {
        let urlString = "http://maps.apple.com/?daddr=\(latitude),\(longitude)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
} // end of Home_Item struct View

#Preview {
    // passing in test arguments
    Home_Item(item: HomeItemModel(
        ID: "testID",
        restoName: "Cava",
        picture: "CAVA",
        rating: 2.5,
        latitude: 33.915436,
        longitude: -117.968712
    ))
}
