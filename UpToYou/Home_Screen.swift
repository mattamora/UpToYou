//
//  ContentView.swift
//  UpToYou
//
//  Created by Matthew Amora on 2/28/25.
//

import SwiftUI

struct Home_Screen: View {
    
    // array of BottomIcons structs
    let bottomItems = [
        BottomIcons(icon: "house", label: "Home"),
        BottomIcons(icon: "list.bullet.circle", label: "List"),
        BottomIcons(icon: "arrow.trianglehead.2.clockwise", label: "Shuffle"),
        BottomIcons(icon: "heart", label: "Favorites"),
        BottomIcons(icon: "person", label: "Profile")
    ]
    
    var mainColor = Color(hue: 1.0, saturation: 0.183, brightness: 0.092)
    var body: some View {
        ZStack {
            mainColor.ignoresSafeArea()

            VStack {
                
                Text("Up To You")
                    .foregroundColor(.gray)
                
                Spacer()
                
                Divider() // adds a line above the HStack
                    .frame(height: 2) // Makes the line thicker
                    .background(Color.gray) // Changes color
                    .padding(.bottom, 20)
                
                HStack {
                    Spacer()
                    ForEach(bottomItems, id: \.label) { item in
                        VStack {
                            Image(systemName: item.icon)
                                .resizable()
                                .frame(width: 33, height: 33)
                            Text(item.label)
                                .font(.caption)
                        }
                        Spacer()
                    }
                }
                .padding(.bottom, 20)
                .foregroundColor(.gray)

                
                
            } // end of VStack
        } // end of ZStack
    } // end of body view
} // end of Home_Screen view

#Preview {
    Home_Screen()
}
