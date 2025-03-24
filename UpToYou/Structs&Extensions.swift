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
import CoreLocation


// main app color, theme color (red)
extension Color {
    static let mainColor = Color(hue: 1.0, saturation: 0.183, brightness: 0.092) // app background color
    static let themeColor = Color(red: 218/255, green: 58/255, blue: 56/255) // logo red color
    static let shadowColor = Color(red: 160/255, green: 20/255, blue: 20/255) // logo shadow color
}

// for showing location services status, displays location status
extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined: return "Not Determined"
        case .restricted: return "Restricted"
        case .denied: return "Do Not Allow"
        case .authorizedAlways: return "Always Allow"
        case .authorizedWhenInUse: return "Allow while using app"
        @unknown default: return "Unknown"
        }
    }
}



// API stuff
struct YelpSearchResponse: Decodable {
    let restos: [Restaurant]
    
    
    // Yelp’s real JSON key is "businesses", not "restos" — so need to fix the mapping.
    // Decodes the businesses key from the JSON into my restos array.
    private enum CodingKeys: String, CodingKey {
           case restos = "businesses"
       }
}
struct Restaurant: Decodable {
    let id: String // business id from Yelp, unique to every restaurant
    let name: String
    let location: Location
    let image_url: String?
    let rating: Double
    let coordinates: Coordinates
    let url: String
}
struct Location: Decodable {
    let address1: String? // used in Favorite_Screen search
    let city: String
    let state: String
}
struct Coordinates: Decodable {
    let latitude: Double
    let longitude: Double
}

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

// an item in the favorites
struct FavoriteItemModel: Codable {
    let ID: String // = UUID() // Unique ID for each item, dont use this for now
    let restoName: String
    let location: String // city, state
    let picture: String
    let rating: Double // rating property (0.0 to 5.0), used for stars
    let latitude: Double  // Needed for directions, arrow button to maps
    let longitude: Double // Needed for directions, arrow button to maps
}










// simpler way to do naviagtion between views, should replace bottom icons
/*
 Other, simpler way to do the bottom navigation
 found this out after already having implemented the bottom navigation HStack
 
 TabView {
     Home_Screen()
         .tabItem {
             Label("Home", systemImage: "house")
         }
     List_Screen()
         .tabItem {
             Label("List", systemImage: "list.bullet.circle.fill")
         }
     Shuffle_Screen()
         .tabItem {
             Label("Shuffle", systemImage: "arrow.trianglehead.2.clockwise")
         }
     Favorites_Screen()
         .tabItem {
             Label("Favorites", systemImage: "heart")
         }
     Profile_Screen()
         .tabItem {
             Label("Profile", systemImage: "person")
         }
 }
 */

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
