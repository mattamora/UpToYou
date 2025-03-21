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
                Image(item.picture) // ← Uses the image name from Firebase
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .cornerRadius(10)
                    

                VStack(alignment: .leading) {
                    Text(item.restoName) // ← Dynamic name
                        .bold()
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                        .offset(y: -5)

                    HStack(spacing: 1) {
                        Image(systemName: "star.fill")
                        Image(systemName: "star.fill")
                        Image(systemName: "star.fill")
                        Image(systemName: "star.leadinghalf.filled")
                        Image(systemName: "star")
                    }
                    .font(.system(size: 9))
                    .foregroundColor(.yellow)
                    .offset(y: -4)

                    Text(item.location) // ← Dynamic location
                        .offset(y: 1)
                        .foregroundColor(.white)
                }
                

                Spacer()

                Image(systemName: "arrow.up.forward.app")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
            } // end of HStack
            .frame(maxWidth: .infinity) //  Expands row fully
            .padding([.top, .bottom], 15) //  Adds padding for spacing
        }
    } // end of body View
} // end of Favorite_Item struct View

#Preview {
    // passing in test arguments
    Favorite_Item(item: FavoriteItemModel(
        ID: "testID",
        restoName: "Cava",
        location: "La Habra, CA",
        picture: "CAVA"
    ))
}


// goes inside HStack, old code, test UI
/*
Image("CAVA")
    .resizable()
    .aspectRatio(contentMode: .fit)
    .frame(width: 100, height: 100)
    .cornerRadius(20)
    .offset(x: 20)
VStack (alignment: .leading) {
    Text("Cava")
        .bold()
        .font(.system(size: 40))
    HStack (spacing: 1) {
        Image(systemName: "star.fill")
        Image(systemName: "star.fill")
        Image(systemName: "star.fill")
        Image(systemName: "star.leadinghalf.filled")
        Image(systemName: "star")
    }
    .font(.system(size: 10))
    Text("La Habra, CA")
        .offset(y: 5)
    
}
.offset(x: 30)

Spacer()
Image(systemName: "arrow.up.forward.app")
    .font(.system(size: 40))
    .offset(x: -30)
*/
