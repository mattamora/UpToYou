//
//  savedData.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/15/25.
//
// view saved data from the popup


import FirebaseFirestore
import SwiftUI

struct savedData: View {
    
    // this screens view model
    @StateObject var savedViewModel = savedDataViewModel()
    
    // a list of Data structs
    // @FirestoreQuery, add, delete, or modify data in Firestore, your SwiftUI views using this variable will instantly refresh, displaying the latest data, real-time updates
    @FirestoreQuery var itemData: [Data]
    
    let userID: String // created to add userID scope in this struct
    // constructor for showing the data of the user
    // _ in front of itemData becuase itemData is wrapped in @FirestoreQuery, _ is always needed to access wrapped variables
    init(userID: String) {
        self.userID = userID
        self._itemData = FirestoreQuery(collectionPath: "Users/\(userID)/Sample Data")
    }
    
    var body: some View {
        Text("Created Data from Popup")
            .multilineTextAlignment(.center)
            .bold()
            .font(.system(size: 30))
            .padding(.top)
        
        // shows created data from popup
        // List is a SwiftUI view that presents rows of data in a scrollable and structured form. Each row within a List can display text, images, buttons, or other custom SwiftUI views. SwiftUI automatically handles the scrolling behavior, selection, editing, and data management efficiently.
        // \.ID is called a key path, instructs SwiftUI to use the ID property of each Data instance to differentiate between each row.
        // .swipeActions adds an interactive swipe gesture action
        // edge: .trailing swipe action appears on the right side, user swipes from right to left
        // allowsFullSwipe: true  If set to false, the user has to explicitly tap the action after the swipe gesture
        // (role: .destructive) Indicates the action has a destructive behavior, showing a red button by default.
        List(itemData, id: \.ID) { item in
            VStack(alignment: .leading) {
                Text(item.title)
                    .font(.headline)
                Text(item.actualData)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    // code to delete this item from firebase
                    Firestore.firestore()
                            .collection("Users").document(userID)
                            .collection("Sample Data").document(item.ID)
                            .delete() { error in
                                if let error = error {
                                    // for debugging only
                                    print("Error deleting document: \(error.localizedDescription)")
                                } else {
                                    print("Item deleted successfully.") // for debugging only
                                }
                            }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }

        
    }
}

#Preview {
    savedData(userID: "4SLAGBjedZSupsRp7T1BVuoBowt1")
}
