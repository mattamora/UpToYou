//
//  Favorite_Item.swift
//  UpToYou
//
//  Created by Maria Lontok on 3/18/25.
//

import SwiftUI

struct Favorite_Item: View {
    
    
    var body: some View {
        HStack {
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
            
            
        }
    } // end of body View
} // end of Favorite_Item struct View

#Preview {
    Favorite_Item()
}
