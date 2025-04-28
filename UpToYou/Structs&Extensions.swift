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
import UIKit

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
    let review_count: Int // used in home screen, Highly rated
    let coordinates: Coordinates // latitude and longitude
    let url: String
    let distance: Double // Yelp provides this in meters, used becuase filter for miles is not entirely accurate
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
struct FavoriteItemModel: Codable, Equatable  {
    let ID: String // = UUID() // Unique ID for each item, dont use this for now
    let restoName: String
    let location: String // city, state
    let picture: String
    let rating: Double // rating property (0.0 to 5.0), used for stars
    let latitude: Double  // Needed for directions, arrow button to maps
    let longitude: Double // Needed for directions, arrow button to maps
}

// an item in the home screen
struct HomeItemModel: Codable {
    let ID: String // = UUID() // Unique ID for each item, dont use this for now
    let restoName: String
    let picture: String
    let rating: Double // rating property (0.0 to 5.0), used for stars
    let latitude: Double // for the distance between the user and the restaurant
    let longitude: Double // for the distance between the user and the restaurant
}


// a list in List_Screen
struct CustomList: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String // List name, e.g., "Date Night Spots"
    var restaurantIDs: [String]? // IDs of restaurants in the list
    var createdDate: Date // for sorting
    var imageURL: String? // uploaded image
}




// for food type options for the filter in Shuffle_Screen (LOWKEY USELSS NOW)
enum FoodType: String, CaseIterable, Identifiable {
    
    // for the view, Ui only
    case any = "Any"
    case burgers = "Burgers"
    case pizza = "Pizza"
    case sushi = "Sushi"
    case tacos = "Tacos"
    case steak = "Steak"
    case fastfood = "Fast Food"
    // add more as needed

    var id: String { self.rawValue }

    // for the filter of Yelp, yelp tags restaurants more reliably by category
    var yelpCategory: String? {
        switch self {
        case .any: return nil // No category filter, show all food
        case .burgers: return "burgers" // case .burgers: return "burgers,fastfood,tradamerican"  can combine categories
        case .pizza: return "pizza"
        case .sushi: return "sushi"
        case .tacos: return "tacos"
        case .steak: return "steak"
        case .fastfood: return "fastfood" // spaces not allowed
        }
    }
}

// which version of Restaurant_Search shows up, either for Favorites_Screen or CreateNewList
enum RestaurantSearchMode {
    case favorites
    case listAdd
}


// for picking a photo from the users library, used in List_Screen, CreateNewList
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }

            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}




// helper class to decode from a dictionary into  FavoriteItemModel
class DictionaryDecoder {
    private let jsonDecoder = JSONDecoder()

    func decode<T>(_ type: T.Type, from dictionary: [String: Any]) throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return try jsonDecoder.decode(T.self, from: data)
    }
}
