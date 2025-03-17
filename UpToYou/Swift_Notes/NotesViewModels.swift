//
//  ViewModels.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/14/25.
//
// Normally all view models for their respective views should be in their own file, but for simplicity I will have them all in here
import SwiftUI
import Foundation

// for adding data into firebase
import FirebaseAuth
import FirebaseFirestore


// view model for main notes page
class swiftNotesViewModel: ObservableObject {
    
    // for showing the error message within the page, accessed with the flag button 
    @Published var showAlert = false
    
    // data to be saved into firebase
    @Published var dataName = ""
    
    init () {}
    
}



// view model for the popup screen
class PopupViewModel: ObservableObject {
    
    @Published var showPopup = false // false first because we don't want to show the popup screen immediately
    @Published var title = ""  // Title of the Data added
    @Published var actualData = ""  // the data to be added into firebase
    
    init() {}
    
    // saves data to firebase collection
    func saveToFirebase() {
        
        // makes sure there is data by calling canSave variable
        guard canSave else {
            print("No data to be saved") // for debugging only
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
        let newData = Data(ID: newID,
                           title: title,  // published variable
                           actualData: actualData,  // published variable
                           creationDate: Date().timeIntervalSince1970)  // current date
        
        
        
        // saves data into a firebase collection
        do {
            // convert newData to dictionary format
            let dataDictionary = try DictionaryEncoder().encode(newData)
            
            // Firestore.firestore() initializes and provides a reference to your Firestore database, connects your app to your Firestore database hosted by Firebase
            // collection in Firestore is like a folder that stores multiple documents.
            // a document in Firestore stores data in key-value pairs
            // Firestore supports nesting collections inside documents, called sub-collections
            Firestore.firestore()
                .collection("Users")   // collection of users, access or create (if it doesn’t already exist) a collection named "users"
                .document(userID)          // specific user, .document(userID) retrieves a specific document inside the collection, userID in this case
                .collection("Sample Data") // sub-collection in a specific user, another smaller folder within that user's specific document
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
    
    // to maake sure data is not empty
    var canSave: Bool {
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }
        
        return true
    }

    
}



// view model for the saveddata screen
class savedDataViewModel: ObservableObject {
    
    // to navigate to this screen
    @Published var showScreen = false
    
    init () {}
    
}



// view model for profile screen
class profileViewModel: ObservableObject {
    init () {}
    
    // to navigate to this screen
    @Published var showScreen = false
    
    // user from firestore databse
    @Published var currentUser: User? = nil
    
    // get specific user from firestore
    func fetchUser() {
        
        // function returns if no user is currently signed in
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is signed in. Stopping function.") // for debugging only
            return
        }
        print("User is signed in with ID: \(userID)") // for debugging only
        
        
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
        
        
    }
    
    // logout functionality
    func logout() {
        
        // Ensure a user is signed in before attempting to log out, for debugging only
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is signed in. Stopping function.") // for debugging only
            return
        }
        print("Logging out user: \(userID)") // for debugging only

        // main logout functionality
        do {
            try Auth.auth().signOut()
            print("User signed out successfully.")
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }

    }
    
}






// MODELS FOR THE SWIFT NOTES

// data struct, used for the data created in Popup
struct Data: Codable {
    let ID: String
    let title: String
    let actualData: String
    let creationDate: TimeInterval
    
}



// uses import Foundation
// to turn struct data into dictionary data for .setData()
struct DictionaryEncoder {
    private let jsonEncoder = JSONEncoder()

    func encode<T>(_ value: T) throws -> [String: Any] where T: Encodable {
        let data = try jsonEncoder.encode(value)
        let json = try JSONSerialization.jsonObject(with: data)
        guard let dictionary = json as? [String: Any] else {
            throw NSError(domain: "Encoding", code: -1, userInfo: nil)
        }
        return dictionary
    }
}



// Helper function to format timestamps, dates, Date().timeIntervalSince1970 to format for readability
// sample usage  formattedDate(from: Date().timeIntervalSince1970)
func formattedDate(from timestamp: TimeInterval) -> String {
    let date = Date(timeIntervalSince1970: timestamp)
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: date)
}






