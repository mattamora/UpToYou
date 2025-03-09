//
//  personal_info.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/2/25.
//
// ViewModel for Profile_Screen, Create_Account_Screen
// Contains User Info

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
        Auth.auth().signIn(withEmail: email, password: password)
        
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
        guard email.contains("@") && email.contains(".")
        else {
            errorMessage = "Enter a Valid Email!"
            print("Validation Function Ran with no invalid email") // debug purposes
            // removes error message after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.errorMessage = ""
            }
            return false
        }
        
        print("Validation Function Ran Normally") // for debugging, making sure function works
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
        }
        
        print("Account Created")  // for debugging purposes
        
        
        
    }
    
    // inserts user into the firebase database
    private func insertUserAccount(ID: String) {
        
        // initializing a new user, uses User struct
        /*
        let newUser = User(ID: ID,
                           name: fullName,
                           email: email,
                           joined: Date().timeIntervalSince1970) */
        
        let database = Firestore.firestore()
        
        let newUserData: [String: Any] = [ // used to pass in .setData to add to firebase database collection
                "ID": ID,
                "name": fullName,
                "email": email,
                "joined": Date().timeIntervalSince1970
            ]
        
        print("Data being sent to Firestore: \(newUserData)") // debugging purposes
        
        database.collection("Users")
            .document(ID)
            .setData(newUserData) { error in
                if let error = error {
                    print("Firestore error: \(error.localizedDescription)")
                } else {
                    print("User successfully added to Firestore!")
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
        guard email.contains("@") && email.contains(".")
        else {
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

// for checking if the user is already signed in when the app opens, skips going to the login page when clicking on profile
class SignedInViewModel: ObservableObject {
    @Published var currentUserID: String = ""
    
    private var handler: AuthStateDidChangeListenerHandle?
    
    init () {
        self.handler = Auth.auth().addStateDidChangeListener { [weak self]_, user in
            DispatchQueue.main.async {
                self?.currentUserID = user?.uid ?? ""
            }
        }
    }
    
    public var isSignedIn: Bool {
        return Auth.auth().currentUser != nil  // if the use
    }
}
