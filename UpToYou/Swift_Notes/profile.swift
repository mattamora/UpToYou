//
//  profile.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/15/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct profile: View {
    @StateObject var userViewModel = profileViewModel()
    
    var body: some View {
        VStack {
            if let currentUser = userViewModel.currentUser {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
                HStack {
                    Text("Joined on:")
                    Text(formattedDate(from: currentUser.joined))
                }
                HStack {
                    Text("Name:")
                    Text(currentUser.name)
                }
                HStack {
                    Text("Email:")
                    Text(currentUser.email)
                }
                
                Button {
                    userViewModel.logout()
                } label : {
                    Text("Logout")
                }
            } else {
                Text("No user signed in...")
            }
            
        } // end of main VStack
        .onAppear {
            userViewModel.fetchUser()
            
            // .onAppear runs a block of code when the view first appears on screen
            // commonly used to fetch data, trigger updates, or perform actions as soon as a view becomes visible
            // fetchUser() retrieves user data from Firestore
            
        } // end of .onAppear modifier
    } // end of body view
}

#Preview {
    profile()
}
