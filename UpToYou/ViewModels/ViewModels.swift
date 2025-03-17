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


// for user login, used in Login_Screen
class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    @Published var errorMessage = ""
    
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
                return
            }
            
            guard let user = result?.user else {
                print("Login error: User object not found")
                return
            }
            
            print("User logged in successfully! UID: \(user.uid)") // for debugging only
            
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
            
            // ensure the created account does not get signed in after creation
            // for some reason creating an account also signs the user in, so I have to sign out after it gets created
            /*
            do {
                try Auth.auth().signOut()
                print("User signed out after account creation.")
            } catch {
                print("Error signing out newly created user: \(error.localizedDescription)")
            }
             */
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
            print("User signed out successfully.") // for debugging only
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)") // for debugging only
        }

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



