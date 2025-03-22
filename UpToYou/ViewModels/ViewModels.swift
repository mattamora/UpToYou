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


// Home_Screen ViewModel, for everything in the Home Screen
class HomeScreenViewModel: ObservableObject {
    init () {}
    @Published var currentUserID: String = ""
    @Published var currentUserName: String = ""
    
    

}


// Profile_Screen ViewModel, for everything related to the Profile Screen
class ProfileScreenViewModel: ObservableObject {
    init() {}
    
    // user from firestore databse
    @Published var currentUser: User? = nil
    
    // logged in or not
    @Published var isLoggedOut = false
    
    // get specific user from firestore
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

// Favorites_Screen ViewModel
class FavoritesScreenViewModel: ObservableObject {
    
    
    init() {}
    
}


// List_Screen ViewModel
class ListScreenViewModel: ObservableObject {
    // for now using this to add an item to favorites
    @Published var restoName = ""  // Restaurant Name
    @Published var location = ""  // location  city,state format, ex. La Habra, CA    Los Angeles, CA
    @Published var picture = ""  // image name, picture of restaurant  Image("")
    @Published var ratingInput = "" // rating of restaurant 0.0-5.0, number of stars to show
    
    init() {}
    
    // saves data to firebase collection
    func saveToFirebase() {
        
        // makes sure there is data by calling canSave variable
        guard canSave else {
            print("Empty data fields") // for debugging only
            return
        }
        
        // restaurant rating
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
                                        picture: picture,
                                        rating: rating)  // image name from assets
        
        
        
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
// this class uses locationManager.requestLocationPermission() for location permission, but will use this later.
class AllowLocation: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        authorizationStatus = locationManager.authorizationStatus
    }

    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
        }
    }
}



