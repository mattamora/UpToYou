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
import FirebaseStorage
import CoreLocation
import UIKit


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
    
    // first name of the current signed in user
    @Published var userFirstName: String = ""
    

    // Fetch User Info, first name specifically
    func fetchUser() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore()
            .collection("Users").document(userID)
            .getDocument { snapshot, error in
                guard let data = snapshot?.data(), error == nil else { return }
                DispatchQueue.main.async {
                    let fullName = data["name"] as? String ?? ""
                    self.userFirstName = fullName.components(separatedBy: " ").first ?? ""
                    self.currentUser = User(ID: userID, name: fullName, email: "", joined: 0)
                }
            }
    }

    // Fetch trending restaurants using Yelp API, within 10 miles
    func fetchTrendingRestaurants(latitude: Double, longitude: Double, completion: @escaping ([Restaurant]) -> Void) {
        let apiKey = "F2Xc6ueipAfk-JX4v0WB2zad-OgR-VJouSl1TNXBNB4dNEPRgW3dVaMT9LdyhgQZLbJbssiNAGlF9Q3rtoJTSgHnPUyniUcc04IlbIp91NkT1e2zebBpHQiqDu0LaHYx"
        let radiusInMeters = 16093 // 10 miles

        let urlString = """
        https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&radius=\(radiusInMeters)&sort_by=review_count&limit=50&categories=restaurants
        """

        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("Invalid URL")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            do {
                let decoded = try JSONDecoder().decode(YelpSearchResponse.self, from: data)

                // Strict filter: Only within 10 miles (Yelp sometimes overflows radius)
                let maxDistanceMeters = 16093.4 // 10 miles
                let filtered = decoded.restos.filter { $0.distance <= maxDistanceMeters }

                // Sort: highest review count + rating (optional combo)
                let sorted = filtered.sorted {
                    if $0.rating == $1.rating {
                        return $0.distance < $1.distance // tie-breaker by distance
                    }
                    return $0.rating > $1.rating
                }

                let topTrending = sorted.prefix(10)

                DispatchQueue.main.async {
                    completion(Array(topTrending))
                }
            } catch {
                print("Decoding error: \(error)")
                completion([])
            }
        }.resume()
    }
    
    // Fetch highly rated restaurants using Yelp API, within 25 miles, 300+ reviews, 4+ stars
    func fetchHighlyRatedRestaurants(latitude: Double, longitude: Double, completion: @escaping ([Restaurant]) -> Void) {
        let apiKey = "F2Xc6ueipAfk-JX4v0WB2zad-OgR-VJouSl1TNXBNB4dNEPRgW3dVaMT9LdyhgQZLbJbssiNAGlF9Q3rtoJTSgHnPUyniUcc04IlbIp91NkT1e2zebBpHQiqDu0LaHYx"
        let radiusInMeters = 32186 // 20 miles EXACT

        let urlString = """
        https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&radius=\(radiusInMeters)&sort_by=review_count&limit=50&categories=restaurants
        """

        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("Invalid URL")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            do {
                let decoded = try JSONDecoder().decode(YelpSearchResponse.self, from: data)

                // STRICT distance filter + review + rating
                let strictMaxDistance = 32186.0 // 20 miles in meters

                let filteredHighlyRated = decoded.restos
                    .filter {
                        $0.rating >= 4.0 &&
                        $0.review_count >= 300 &&
                        $0.distance <= strictMaxDistance // Force strictly ≤ 20 miles
                    }
                    .sorted {
                        // Sort: highest review count, then rating
                        if $0.review_count == $1.review_count {
                            return $0.rating > $1.rating
                        } else {
                            return $0.review_count > $1.review_count
                        }
                    }

                let top10 = filteredHighlyRated.prefix(10)

                DispatchQueue.main.async {
                    completion(Array(top10))
                }
            } catch {
                print("Decoding error: \(error)")
                completion([])
            }
        }.resume()
    }
    
    // Fetch cheap restaurants using Yelp API, within 20 miles, $ price, 4+ stars
    func fetchBudgetRestaurants(latitude: Double, longitude: Double, completion: @escaping ([Restaurant]) -> Void) {
        let apiKey = "F2Xc6ueipAfk-JX4v0WB2zad-OgR-VJouSl1TNXBNB4dNEPRgW3dVaMT9LdyhgQZLbJbssiNAGlF9Q3rtoJTSgHnPUyniUcc04IlbIp91NkT1e2zebBpHQiqDu0LaHYx"
        let radiusInMeters = 32186 // 20 miles

        let urlString = """
        https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&radius=\(radiusInMeters)&price=1&sort_by=best_match&limit=50&categories=restaurants
        """

        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else {
            print("Invalid URL")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }

            do {
                let decoded = try JSONDecoder().decode(YelpSearchResponse.self, from: data)
                let filteredBudget = decoded.restos
                    .filter {
                        $0.rating >= 4.0 &&
                        $0.distance <= Double(radiusInMeters)
                    }
                    .shuffled() // Randomize

                let top10 = filteredBudget.prefix(10)

                DispatchQueue.main.async {
                    completion(Array(top10))
                }
            } catch {
                print("Decoding error: \(error)")
                completion([])
            }
        }.resume()
    }
    
    // Todays pick, random restaurant from user favorites
    @Published var todaysPick: FavoriteItemModel? = nil
    func loadTodaysPick(from favorites: [FavoriteItemModel]) {
        // Check if we have a stored pick and it's still valid
        if let storedPickData = UserDefaults.standard.data(forKey: "todaysPick"),
           let storedPick = try? JSONDecoder().decode(FavoriteItemModel.self, from: storedPickData),
           let storedTime = UserDefaults.standard.object(forKey: "todaysPickTime") as? Date {
            
            let twelveHoursLater = storedTime.addingTimeInterval(12 * 60 * 60)
            
            if Date() < twelveHoursLater {
                // Within 12 hours, use stored pick
                self.todaysPick = storedPick
                return
            }
        }

        // Otherwise, pick a new random favorite
        if let newPick = favorites.randomElement() {
            self.todaysPick = newPick

            // Save to UserDefaults
            if let encoded = try? JSONEncoder().encode(newPick) {
                UserDefaults.standard.set(encoded, forKey: "todaysPick")
                UserDefaults.standard.set(Date(), forKey: "todaysPickTime")
            }
        }
    }








    /* OG FETCH USER AND FIRST NAME EXTRACTION, feel free to delete when home screen is all done
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
     */

    
}

class HomeSaveViewModel: ObservableObject {
    @Published var userLists: [CustomList] = []
    
    init() {
        fetchUserLists()
    }
    
    func fetchUserLists() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("Users").document(userID)
            .collection("Lists")
            .order(by: "createdDate", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching lists: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else { return }

                self.userLists = documents.compactMap { doc in
                    try? doc.data(as: CustomList.self)
                }
            }
    }
    
    func saveRestaurantToSelectedLists(item: HomeItemModel, selectedIDs: Set<String>, completion: @escaping () -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        let db = Firestore.firestore()

        let group = DispatchGroup() // Track all save operations

        for id in selectedIDs {
            if id == "favorites-id" {
                // Save to Favorites
                group.enter()
                let newItem = FavoriteItemModel(
                    ID: item.ID,
                    restoName: item.restoName,
                    location: "\(item.city), \(item.state)",
                    picture: item.picture,
                    rating: item.rating,
                    latitude: item.latitude,
                    longitude: item.longitude
                )
                do {
                    let data = try DictionaryEncoder().encode(newItem)
                    db.collection("Users").document(userID)
                        .collection("Favorite Restaurants").document(item.ID)
                        .setData(data) { error in
                            if let error = error {
                                print("Error saving to Favorites: \(error.localizedDescription)")
                            }
                            group.leave()
                        }
                } catch {
                    print("Encoding error: \(error.localizedDescription)")
                    group.leave()
                }

            } else {
                // Save to a List's restaurants array
                group.enter()
                let restaurantData: [String: Any] = [
                    "id": item.ID,
                    "name": item.restoName,
                    "image_url": item.picture,
                    "rating": item.rating,
                    "location": [
                        "city": item.city,
                        "state": item.state
                    ],
                    "coordinates": [
                        "latitude": item.latitude,
                        "longitude": item.longitude
                    ]
                ]

                let listRef = db.collection("Users").document(userID).collection("Lists").document(id)
                listRef.updateData([
                    "restaurants": FieldValue.arrayUnion([restaurantData])
                ]) { error in
                    if let error = error {
                        print("Error saving to List: \(error.localizedDescription)")
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            completion()
        }
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

class RestaurantSearchViewModel: ObservableObject { // this view is used in the Favorites_Screen and List_Screen, shows 10 restaurants only for now
    
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
    @Published var userLists: [CustomList] = []

    func fetchUserLists() {
        guard let userID = Auth.auth().currentUser?.uid else { return }

        Firestore.firestore()
            .collection("Users").document(userID)
            .collection("Lists")
            .order(by: "createdDate", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching lists: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No documents found")
                    return
                }

                self.userLists = documents.compactMap { doc in
                    do {
                        let list = try doc.data(as: CustomList.self)
                        print("Fetched list: \(list.name)") // DEBUG: Show fetched list names
                        return list
                    } catch {
                        print("Decoding error for document \(doc.documentID): \(error.localizedDescription)")
                        return nil
                    }
                }
            }
    }

}

class CreateListViewModel: ObservableObject {
    @Published var listTitle: String = ""
    @Published var selectedImage: UIImage? = nil
    @Published var selectedRestaurants: [Restaurant] = []
    @Published var searchText: String = ""
    @Published var showImagePicker: Bool = false
    @Published var showRestaurantSearchSheet: Bool = false
    @Published var showErrorAlert: Bool = false
    
    /* not needed anymore
    func saveListToFirebase() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }

        let restaurantDataArray: [[String: Any]] = selectedRestaurants.map { restaurant in
            return [
                "id": restaurant.id,
                "name": restaurant.name,
                "image_url": restaurant.image_url ?? "",
                "rating": restaurant.rating,
                "location": [
                    "address1": restaurant.location.address1 ?? "",
                    "city": restaurant.location.city,
                    "state": restaurant.location.state
                ],
                "coordinates": [
                    "latitude": restaurant.coordinates.latitude,
                    "longitude": restaurant.coordinates.longitude
                ]
            ]
        }

        let newList = CustomList(
            id: nil,
            name: listTitle,
            restaurantIDs: selectedRestaurants.map { $0.id },
            createdDate: Date()
        )

        let data: [String: Any] = [
            "name": newList.name,
            "createdDate": Timestamp(date: newList.createdDate),
            "restaurants": restaurantDataArray
        ]

        Firestore.firestore()
            .collection("Users").document(userID)
            .collection("Lists").addDocument(data: data) { error in
                if let error = error {
                    print("Error saving list: \(error.localizedDescription)")
                } else {
                    print("List saved successfully")
                }
            }
    } */
    
    // has image saving
    func saveListToFirebase() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user logged in")
            return
        }

        let restaurantDataArray: [[String: Any]] = selectedRestaurants.map { restaurant in
            return [
                "id": restaurant.id,
                "name": restaurant.name,
                "image_url": restaurant.image_url ?? "",
                "rating": restaurant.rating,
                "location": [
                    "address1": restaurant.location.address1 ?? "",
                    "city": restaurant.location.city,
                    "state": restaurant.location.state
                ],
                "coordinates": [
                    "latitude": restaurant.coordinates.latitude,
                    "longitude": restaurant.coordinates.longitude
                ]
            ]
        }

        let createdDate = Date()

        var data: [String: Any] = [
            "name": listTitle,
            "createdDate": Timestamp(date: createdDate),
            "restaurants": restaurantDataArray
        ]

        let firestore = Firestore.firestore()
        let listRef = firestore.collection("Users").document(userID).collection("Lists").document()

        listRef.setData(data) { error in
            if let error = error {
                print("Error saving list: \(error.localizedDescription)")
            } else {
                print("List saved successfully.")
                // Upload image if selected
                if let image = self.selectedImage {
                    self.uploadImage(image, for: listRef.documentID, userID: userID)
                }
            }
        }
    }
    
    private func uploadImage(_ image: UIImage, for listID: String, userID: String) {
        let storageRef = Storage.storage().reference().child("Users").child(userID).child("ListImages").child("\(listID).jpg")

        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Image upload error: \(error.localizedDescription)")
                return
            }

            storageRef.downloadURL { url, error in
                if let url = url {
                    Firestore.firestore().collection("Users").document(userID).collection("Lists").document(listID).updateData([
                        "imageURL": url.absoluteString
                    ]) { error in
                        if let error = error {
                            print("Error saving image URL: \(error.localizedDescription)")
                        } else {
                            print("Image URL saved successfully.")
                        }
                    }
                }
            }
        }
    }
    
}

class ListSheetViewModel: ObservableObject {
    let list: CustomList
    @Published var favoriteItems: [FavoriteItemModel] = []

    init(list: CustomList) {
        self.list = list
        fetchRestaurantsFromListDocument()
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: list.createdDate)
    }

    // Fetch restaurants stored in the 'restaurants' field of this list
    private func fetchRestaurantsFromListDocument() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()

        db.collection("Users").document(userID).collection("Lists").document(list.id ?? "")
            .getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    if let restaurantsArray = data["restaurants"] as? [[String: Any]] {
                        var fetchedItems: [FavoriteItemModel] = []
                        for restaurantData in restaurantsArray {
                            if let id = restaurantData["id"] as? String,
                               let name = restaurantData["name"] as? String,
                               let picture = restaurantData["image_url"] as? String,
                               let rating = restaurantData["rating"] as? Double,
                               let locationDict = restaurantData["location"] as? [String: Any],
                               let city = locationDict["city"] as? String,
                               let state = locationDict["state"] as? String,
                               let coordinatesDict = restaurantData["coordinates"] as? [String: Any],
                               let latitude = coordinatesDict["latitude"] as? Double,
                               let longitude = coordinatesDict["longitude"] as? Double {

                                let locationString = "\(city), \(state)"

                                let item = FavoriteItemModel(
                                    ID: id,
                                    restoName: name,
                                    location: locationString,
                                    picture: picture,
                                    rating: rating,
                                    latitude: latitude,
                                    longitude: longitude
                                )

                                fetchedItems.append(item)
                            } else {
                                print("Error mapping restaurant: \(restaurantData)")
                            }
                        }
                        DispatchQueue.main.async {
                            self.favoriteItems = fetchedItems
                        }
                    } else {
                        print("No restaurants found in list document")
                    }
                } else if let error = error {
                    print("Error fetching list document: \(error.localizedDescription)")
                }
            }
    }

}

class ShuffleScreenViewModel: ObservableObject {
    init() {}

    @Published var shuffledRestaurant: FavoriteItemModel? = nil
    @Published var shufflePool: [FavoriteItemModel] = []

    // Update pool depending on source: Favorites or List
    func updateShufflePool(from source: String, lists: [CustomList], favorites: [FavoriteItemModel], completion: @escaping () -> Void) {
        if source == "Favorites" {
            shufflePool = favorites
            completion()
        } else if let selectedList = lists.first(where: { $0.name == source }) {
            fetchRestaurantsForList(selectedList) { fetchedItems in
                self.shufflePool = fetchedItems
                completion()
            }
        } else {
            shufflePool = []
            completion()
        }
    }

    // Fetch restaurants stored in Firestore for the selected list
    private func fetchRestaurantsForList(_ list: CustomList, completion: @escaping ([FavoriteItemModel]) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid, let listID = list.id else {
            completion([])
            return
        }

        let db = Firestore.firestore()
        db.collection("Users").document(userID).collection("Lists").document(listID)
            .getDocument { snapshot, error in
                if let data = snapshot?.data(), let restaurantsArray = data["restaurants"] as? [[String: Any]] {
                    var items: [FavoriteItemModel] = []
                    for restaurantData in restaurantsArray {
                        if let item = self.mapRestaurantDataToFavoriteItem(data: restaurantData) {
                            items.append(item)
                        }
                    }
                    DispatchQueue.main.async {
                        completion(items)
                    }
                } else {
                    print("Error fetching restaurants for list: \(error?.localizedDescription ?? "unknown error")")
                    completion([])
                }
            }
    }

    // Helper to map each dictionary into a FavoriteItemModel
    private func mapRestaurantDataToFavoriteItem(data: [String: Any]) -> FavoriteItemModel? {
        guard let id = data["id"] as? String,
              let name = data["name"] as? String,
              let picture = data["image_url"] as? String,
              let rating = data["rating"] as? Double,
              let locationDict = data["location"] as? [String: Any],
              let city = locationDict["city"] as? String,
              let state = locationDict["state"] as? String,
              let coordinatesDict = data["coordinates"] as? [String: Any],
              let latitude = coordinatesDict["latitude"] as? Double,
              let longitude = coordinatesDict["longitude"] as? Double else {
            return nil
        }

        let locationString = "\(city), \(state)"

        return FavoriteItemModel(
            ID: id,
            restoName: name,
            location: locationString,
            picture: picture,
            rating: rating,
            latitude: latitude,
            longitude: longitude
        )
    }
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
    static let shared = LocationManager()  // Singleton Instance

    private let manager = CLLocationManager()

    @Published var userLocation: CLLocationCoordinate2D?
    @Published var permissionDenied: Bool = false
    @Published var cityAndState: String? = nil  // "city, state", for Profile_Screen

    //  Make init private so no one else creates new instances
    private override init() {
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

        DispatchQueue.main.async {
            self.userLocation = location.coordinate
        }

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

