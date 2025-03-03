//
//  Structs.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/1/25.
//
// Contains all the structs and definitions used for Up To You

import SwiftUI

// main app color
extension Color {
    static let mainColor = Color(hue: 1.0, saturation: 0.183, brightness: 0.092) // app background color
    static let themeColor = Color(red: 218/255, green: 58/255, blue: 56/255) // logo red color
}


// Bottom Icons
struct BottomIcons {
    let icon: String  // SF Symbol name
    let label: String // Text label
}


/* // array of BottomIcons structs, used for ForEach Loop
let bottomItems = [
    BottomIcons(icon: "house", label: "Home"),
    BottomIcons(icon: "list.bullet.circle", label: "List"),
    BottomIcons(icon: "arrow.trianglehead.2.clockwise", label: "Shuffle"),
    BottomIcons(icon: "heart", label: "Favorites"),
    BottomIcons(icon: "person", label: "Profile")
]
*/




