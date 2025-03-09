//
//  Structs.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/1/25.
//
// Contains all the structs and definitions used for Up To You

import SwiftUI
import FirebaseAuth
import FirebaseFirestore


// main app color, theme color (red)
extension Color {
    static let mainColor = Color(hue: 1.0, saturation: 0.183, brightness: 0.092) // app background color
    static let themeColor = Color(red: 218/255, green: 58/255, blue: 56/255) // logo red color
}

// maakes struct User info into a dictionary, used to simplify storing user data into firebase, .setData( used for this ), does not work well so currently not using this. Supposed to be used in Login_SignUp file in create_account() funtion
/* extension Encodable {
    func asDictionary() -> [String: Any] {
        guard let userData = try? JSONEncoder().encode(self) else {
            return [:]  // returns an empty dictionary if no data is given
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: userData) as? [String: Any]
            return json ?? [:]
        } catch {
            return [:] // returns an empty dictionary if error is found
        }
    }
}
*/




// Bottom Icons, used in all main screens
struct BottomIcons {
    let icon: String  // SF Symbol name
    let label: String // Text label
}

// User info and properties, used in Login_Screen, Create_Account Screen
struct User: Codable {
    let ID: String
    let name: String
    let email: String
    let joined: TimeInterval // when the user signed up or made an account
}



