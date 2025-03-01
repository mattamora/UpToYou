//
//  Structs.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/1/25.
//
// Contains all the structs used for Up To You

// Bottom Icons
struct BottomIcons {
    let icon: String  // SF Symbol name
    let label: String // Text label
}

// OG HStack before BottomIcons struct and ForEach implementations
/*
HStack {
    Spacer()
    VStack {
        Image(systemName: "house")
            .resizable() // Makes the image scalable
            .frame(width: 30, height: 30) // Sets a specific size
        Text("Home")
    }
    Spacer()
    VStack {
        Image(systemName: "list.bullet.circle")
            .resizable() // Makes the image scalable
            .frame(width: 30, height: 30) // Sets a specific size
        Text("List")
    }
    Spacer()
    VStack {
        Image(systemName: "arrow.trianglehead.2.clockwise")
            .resizable() // Makes the image scalable
            .frame(width: 30, height: 30) // Sets a specific size
        Text("Shuffle")
    }
    Spacer()
    VStack {
        Image(systemName: "heart")
            .resizable() // Makes the image scalable
            .frame(width: 30, height: 30) // Sets a specific size
        Text("Favorites")
    }
    Spacer()
    VStack {
        Image(systemName: "person")
            .resizable() // Makes the image scalable
            .frame(width: 30, height: 30) // Sets a specific size
        Text("Profile")
    }
    Spacer()
}
*/
