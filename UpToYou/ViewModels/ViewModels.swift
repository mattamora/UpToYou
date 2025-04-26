//
//  personal_info.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/2/25.
//
// ViewModels, normally, should all be in separate files

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import CoreLocation


// for user login, used in Login_Screen
class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var errorMessage = ""
    @Published var isLoggedIn = false
    
    init() { }
    
    // login button on Login_Screen
    func Login() {
        
        guard Validation() else {
            return
        }
        
        // Logging in
        //Auth.auth().signIn(withEmail: email, password: password)
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Login failed: \(error.localizedDescription)")
                print("Invalid email or password!")
                self.invalid()
                return
            }
            
            guard let user = result?.user else {
                print("Login error: User object not found")
                return
            }
            
            print("User logged in successfully! UID: \(user.uid)") // for debugging only
            self.isLoggedIn = true
            
            // Fetch and print the user's name from Firestore
            //self?.fetchUserName(userID: user.uid)
        }
        
    }
    
    // Validate email and passsword fields, returns true if everything is valid
    private func Validation() -> Bool {
        errorMessage = ""
        
        // makes sure there is input in the email and password forms
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            errorMessage = "Fill Out All Fields!"
            print("Validation Function Ran with no Fields") // for debugging, making sure function works
            
            // removes error message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.errorMessage = ""
            }
            return false
        }
        
        // makes sure email is has @ and .
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Enter a Valid Email!"
            print("Validation Function Ran with no invalid email") // debug purposes
            // removes error message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.errorMessage = ""
            }
            return false
        }
        
        return true
    }
    
    // prints error message of an invalid email or password,
    private func invalid() {
        errorMessage = "Invalid email or password!"
        // removes error message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.errorMessage = ""
        }
    }
    
    
} // end of LoginViewModel

// create a user account, used in Create_Account_Screen
class CreateAccountViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var errorMessage = ""
    
    init() {}
    
    // creates a user in the firebase database
    func create_account() {
        guard Validation() else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let userID = result?.user.uid else {
                return
            }
            
            self?.insertUserAccount(ID: userID)

        }
        
        // removes message after 2 seconds, for successful account creation
        errorMessage = "Account Created!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.errorMessage = ""
        }
        
        // ensure the created account does not get signed in after creation
        // for some reason creating an account also signs the user in, so I have to sign out after it gets created
        do {
            try Auth.auth().signOut()
            print("User signed out after account creation.")
        } catch {
            print("Error signing out newly created user: \(error.localizedDescription)")
        }
    }
    
    // inserts user into the firebase database
    private func insertUserAccount(ID: String) {
        
        let newUserData: [String: Any] = [ // used to pass in .setData to add to firebase database collection
                "ID": ID,
                "name": fullName,
                "email": email,
                "joined": Date().timeIntervalSince1970
            ]
        
        Firestore.firestore()
            .collection("Users").document(ID)
            .setData(newUserData) { error in
                if let error = error {
                    print("Firestore error: \(error.localizedDescription)")
                } else {
                    print("User successfully added to Firestore!")
                    print("Data being sent to Firestore: \(newUserData)") // debugging purposes
                }
            } // takes dictionaries as argument, added error handling for collection addition
        
    }
    
    // Validate creation of email, passsword, and full name fields, returns true if everything is valid
    private func Validation() -> Bool {
        errorMessage = ""
        
        // makes sure there is input in the email and password forms
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              !fullName.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            errorMessage = "Fill Out All Fields!"
            
            // removes error message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.errorMessage = ""
            }
            return false
        }
        
        // makes sure email is has @ and .
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Enter a Valid Email!"
    
            // removes error message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.errorMessage = ""
            }
            return false
        }
        
        // makes sure password is 7 characters or more
        guard password.count >= 7 else {
            errorMessage = "Password Too Short!"
            
            // removes error message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.errorMessage = ""
            }
            return false
        }
        
        return true
    }
    
}

class HomeScreenViewModel: ObservableObject {
    init() {}
    
    // user from firestore databse
    @Published var currentUser: User? = nil
    
    // get specific user from firestore, updates currentUser to actual current user
    func fetchUser() {
        
        // function returns if no user is currently signed in
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is signed in. Stopping fetchUser()") // for debugging only
            return
        }
        
        
        // fetches current signed in user
        Firestore.firestore()
            .collection("Users").document(userID).getDocument { [weak self] snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    return
                }
                
                // uses User Struct from structs&extensions file
                DispatchQueue.main.async {
                    self?.currentUser = User(ID: data["ID"] as? String ?? "",
                                      name: data["name"] as? String ?? "",
                                      email: data["email"] as? String ?? "",
                                      joined: data["joined"] as? TimeInterval ?? 0)
                }
            }
        
        print("Fetched user: \(userID)") // for debugging only
        
    }
    
    // Extract first name from full name
    var userFirstName: String {
        guard let fullName = currentUser?.name else {
            return "User"
        }
        let nameComponents = fullName.split(separator: " ")
        return nameComponents.first.map(String.init) ?? fullName
    }

    
}

class ProfileScreenViewModel: ObservableObject {
    init() {}
    
    // user from firestore databse
    @Published var currentUser: User? = nil
    
    // logged in or not
    @Published var isLoggedOut = false
    
    // get specific user from firestore, updates currentUser to actual current user
    func fetchUser() {
        
        // function returns if no user is currently signed in
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is signed in. Stopping fetchUser()") // for debugging only
            return
        }
        
        
        // fetches current signed in user
        Firestore.firestore()
            .collection("Users").document(userID).getDocument { [weak self] snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    return
                }
                
                // uses User Struct from structs&extensions file
                DispatchQueue.main.async {
                    self?.currentUser = User(ID: data["ID"] as? String ?? "",
                                      name: data["name"] as? String ?? "",
                                      email: data["email"] as? String ?? "",
                                      joined: data["joined"] as? TimeInterval ?? 0)
                }
            }
        
        print("Fetched user: \(userID)") // for debugging only
        
    }
    
    // logout functionality
    func logout() {
        
        // for debugging purposes, prints the user being logged out
        if let userID = Auth.auth().currentUser?.uid {
            print("Logging out user: \(userID)")  // DEBUGGING ONLY
        } else {
            assertionFailure("Unexpected nil: No user logged in")
        }

        // main logout functionality
        do {
            try Auth.auth().signOut()
            print("User Logged out successfully.") // for debugging only
        } catch let signOutError as NSError {
            print("Error Logging out: \(signOutError.localizedDescription)") // for debugging only
        }
        
        self.isLoggedOut = true

    }
    
}

class FavoritesScreenViewModel: ObservableObject {
    
    init() {}
    
    // user from firestore databse
    @Published var currentUser: User? = nil
    
    // get specific user from firestore, updates currentUser to actual current user
    func fetchUser() {
        
        // function returns if no user is currently signed in
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is signed in. Stopping fetchUser()") // for debugging only
            return
        }
        
        
        // fetches current signed in user
        Firestore.firestore()
            .collection("Users").document(userID).getDocument { [weak self] snapshot, error in
                guard let data = snapshot?.data(), error == nil else {
                    return
                }
                
                // uses User Struct from structs&extensions file
                DispatchQueue.main.async {
                    self?.currentUser = User(ID: data["ID"] as? String ?? "",
                                      name: data["name"] as? String ?? "",
                                      email: data["email"] as? String ?? "",
                                      joined: data["joined"] as? TimeInterval ?? 0)
                }
            }
        
        print("Fetched user: \(userID)") // for debugging only
        
    }
}

class RestaurantSearchViewModel: ObservableObject { // this view is used in the Favorites_Screen, shows 10 restaurants only for nowte
    
    @Published var results: [Restaurant] = []
    @Published var isLoading = false

    // uses Yelp API to search for restaurant name, shows all restaurants within 25 miles (40000 meters)
    func searchYelp(for term: String, latitude: Double, longitude: Double) {
        guard !term.trimmingCharacters(in: .whitespaces).isEmpty else {
            self.results = []
            return
        }

        isLoading = true

        let apiKey = "F2Xc6ueipAfk-JX4v0WB2zad-OgR-VJouSl1TNXBNB4dNEPRgW3dVaMT9LdyhgQZLbJbssiNAGlF9Q3rtoJTSgHnPUyniUcc04IlbIp91NkT1e2zebBpHQiqDu0LaHYx"
        
        let cleanTerm = term.replacingOccurrences(of: " ", with: "")
        let encodedTerm = cleanTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cleanTerm // handles restaurants with spaces in their names, joins strings with spaces, Panda Express into PandaExpress. Better for yelps search results.
        let urlString = "https://api.yelp.com/v3/businesses/search?term=\(encodedTerm)&latitude=\(latitude)&longitude=\(longitude)&radius=40000&sort_by=distance&limit=10&categories=restaurants,food"

        
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("Invalid URL")
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data")
                return
            }

            do {
                let decoded = try JSONDecoder().decode(YelpSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.results = decoded.restos
                }
            } catch {
                print("Decoding error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.results = []
                }
            }
        }.resume()
    }
    
    // user favorite restaurants, also stored in firebase
    @Published var favoriteIDs: Set<String> = []
    func loadFavorites() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("Users").document(userID)
            .collection("Favorite Restaurants")
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    let ids = documents.map { $0.documentID }
                    DispatchQueue.main.async {
                        self.favoriteIDs = Set(ids)
                    }
                }
            }
    }
    
    // adds restaurant to favorites, and fills the heart, does not remove from favorites if pressed again
    func addToFavorites(restaurant: Restaurant) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let docID = restaurant.id

        // Skip if already in favorites
        if favoriteIDs.contains(docID) { return }

        // Convert to FavoriteItemModel
        let newItem = FavoriteItemModel(
            ID: docID,
            restoName: restaurant.name,
            location: "\(restaurant.location.city), \(restaurant.location.state)",
            picture: restaurant.image_url ?? "",
            rating: restaurant.rating,
            latitude: restaurant.coordinates.latitude,
            longitude: restaurant.coordinates.longitude
        )


        do {
            let data = try DictionaryEncoder().encode(newItem)
            Firestore.firestore()
                .collection("Users").document(userID)
                .collection("Favorite Restaurants").document(docID)
                .setData(data) { error in
                    if let error = error {
                        print("Firestore save error: \(error.localizedDescription)")
                    } else {
                        DispatchQueue.main.async {
                            self.favoriteIDs.insert(docID) // update UI immediately
                        }
                    }
                }
        } catch {
            print("Encoding error: \(error)")
        }
    }

}

class ListScreenViewModel: ObservableObject {
    init() {}
    
    @Published var restaurants: [Restaurant] = []
    @Published var isLoading: Bool = false

    // API stuff, Using Yelp Fusion API to get restaurants
    func fetchYelpRestaurants(latitude: Double, longitude: Double, distanceInMiles: Int, foodType: FoodType) {
        
        isLoading = true // show loading if data fetch is taking too long
        restaurants = [] // Clear old results
        
        // Convert miles to meters (1 mile = 1609.34 meters), Yelp only takes in meters, Yelp max is 40,000 meters or 25 miles
        let radius = min(Int(Double(distanceInMiles) * 1609.34), 40000)
        
        // for the food type filter
        let categoryParam: String
        if let category = foodType.yelpCategory {
            categoryParam = category
        } else {
            categoryParam = "restaurants,food"
        }

        let apiKey = "F2Xc6ueipAfk-JX4v0WB2zad-OgR-VJouSl1TNXBNB4dNEPRgW3dVaMT9LdyhgQZLbJbssiNAGlF9Q3rtoJTSgHnPUyniUcc04IlbIp91NkT1e2zebBpHQiqDu0LaHYx"
        let urlString = "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&radius=\(radius)&categories=\(categoryParam)&sort_by=distance&limit=10" // use &sort_by=rating if u want to sort it by highest rating to least
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("Invalid URL")
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let error = error {
                print("Request error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("No data received")
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(YelpSearchResponse.self, from: data)

                // some restaurants, farther than the within mile disatnce, appear in the search results, so this changes that
                let maxDistanceMeters = Double(distanceInMiles) * 1609.34
                let filtered = decodedResponse.restos.filter {
                    $0.distance <= maxDistanceMeters
                }

                DispatchQueue.main.async {
                    self.restaurants = filtered
                }
                
            } catch {
                print("Decoding error: \(error.localizedDescription)")
            }

        }.resume()
    }

    
    // Favorite_Item view expects a FavoriteItemModel, but Yelp API gives you Restaurant, so we make a small converter function.
    // used to input Yelp data into Favorite_Item view
    func convertToFavoriteModel(_ r: Restaurant) -> FavoriteItemModel {
        return FavoriteItemModel(
            ID: r.url,
            restoName: r.name,
            location: "\(r.location.city), \(r.location.state)",
            picture: r.image_url ?? "placeholder_image", // default fallback
            rating: r.rating,
            latitude: r.coordinates.latitude,
            longitude: r.coordinates.longitude
        )
    }

    
    // OG code for this model
    /*
    // for now using this to add an item to favorites
    @Published var restoName = ""  // Restaurant Name
    @Published var location = ""  // location  city,state format, ex. La Habra, CA    Los Angeles, CA
    @Published var picture = ""  // image name, picture of restaurant  Image("")
    @Published var ratingInput = "" // rating of restaurant 0.0-5.0, number of stars to show
    @Published var longitude = 0.0  // for arrow button
    @Published var latitude = 0.0  // for arrow button
    
    
    // saves data to firebase collection
    func saveToFirebase() {
        
        // makes sure there is data by calling canSave variable
        guard canSave else {
            print("Empty data fields") // for debugging only
            return
        }
        
        // restaurant rating, uses ratingInput to convert into a double
        guard let rating = Double(ratingInput), rating >= 0.0, rating <= 5.0 else {
            print("Invalid rating. Enter a number between 0.0 and 5.0.") //  Validation
            return
        }

        // get current user id
        // Auth.auth() is from Firebase Authentication, used to manage user sign-in states
        // Each Firebase user has a unique identifier called a User ID (UID), currentUser?.uid tries to access the user's UID,
        // ? is used because if there's no user signed in (currentUser is nil), this safely returns nil instead of causing a crash.
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is signed in. Stopping function.") // for debugging only
            return
        }
        print("User is signed in with ID: \(userID)") // for debugging only
        
        
        
        // create a model for the data to be added into the collection
        // UUID() generates a completely unique identifier (UUID)
        let newID = UUID().uuidString   // every time this line runs, it gives you a brand new, unique string that can never repeat
        let newItem = FavoriteItemModel(ID: newID,
                                        restoName: restoName,  // restaurant name
                                        location: location,  // location  city, state
                                        picture: picture, // image name from assets
                                        rating: rating,
                                        latitude: latitude,
                                        longitude: longitude)
        
        
        
        // saves data into a firebase collection
        do {
            // convert newItem to dictionary format
            let dataDictionary = try DictionaryEncoder().encode(newItem)
            
            // Firestore.firestore() initializes and provides a reference to your Firestore database, connects your app to your Firestore database hosted by Firebase
            // collection in Firestore is like a folder that stores multiple documents.
            // a document in Firestore stores data in key-value pairs
            // Firestore supports nesting collections inside documents, called sub-collections
            Firestore.firestore()
                .collection("Users")   // collection of users, access or create (if it doesn’t already exist) a collection named "users"
                .document(userID)          // specific user, .document(userID) retrieves a specific document inside the collection, userID in this case
                .collection("Sample Favorites") // sub-collection in a specific user, another smaller folder within that user's specific document
                .document(newID)           // new data within the "Sample Data" sub-collection, If it doesn't exist, Firestore will automatically create it
                .setData(dataDictionary) { error in // creates or overwrites the document data with the data provided
                    if let error = error {
                        print("Error saving data: \(error.localizedDescription)")
                    } else {
                        print("Data successfully saved with ID: \(newID)")
                    }
                }
        } catch {
            print("Error encoding newData: \(error.localizedDescription)")  // for debugging only
        }
        
    } // end of saveToFirebase()
    
    // to maake sure data form is not empty
    var canSave: Bool {
        guard !restoName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        guard !location.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        guard !picture.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        guard !ratingInput.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
       
        
        return true
    } */
    
}

class ShuffleScreenViewModel: ObservableObject {
    init() {}
    
    @Published var shuffledRestaurant: FavoriteItemModel? = nil

}





// checks if the user is signed in and modifies the variable isSignedIn accordingly
// used in the UpToYouApp file in the @main struct
class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        self.authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isSignedIn = user != nil
            }
        }
    }
}


// asks the user if the app can view their location
// currently using MapKit and CLLocationManager().requestWhenInUseAuthorization() to ask for location permission
// manage current location, used in Restaurant_Search, Profile_Screen,
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var permissionDenied: Bool = false
    @Published var cityAndState: String? = nil  // string version of latitude and longitude, "city, state", shown in Profile_Screen

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        checkLocationAuthorization()
    }

    func checkLocationAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            permissionDenied = true
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        @unknown default:
            break
        }
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        // Save coordinate for map/search usage
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }

        // Reverse geocode for city + state display, in Profile_Screen, updates this classes cityAndState based on current latitude and longitude
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? ""
                let state = placemark.administrativeArea ?? ""
                DispatchQueue.main.async {
                    self.cityAndState = "\(city), \(state)"
                }
            } else if let error = error {
                print("Geocoding failed: \(error.localizedDescription)")
            }
        }
    }


    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}

