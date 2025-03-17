//
//  COMPLETELY SEPARATE FROM MAIN UP TO YOU PROJECT
//
//  Created by Matthew Amora on 3/11/25.
//

import FirebaseFirestore
import SwiftUI

// public because I want files from other folders to access this, default is internal (only files in this folder can access this)
public struct swift_notes_code: View {
    
    // for this view screens view model
    // used for the flag button
    @StateObject var notesViewModel = swiftNotesViewModel()
    
    // for the PopupViewModel() to be used with the Popup() view
    // used for binding variable in .sheet
    @StateObject var popViewModel = PopupViewModel()
    
    // for the savedDataViewModel() to be used with the savedData() view
    @StateObject var savedViewModel = savedDataViewModel()
    
    // for the profileVewModel() to be used with the person image
    @StateObject var userViewModel = profileViewModel()
    
    
    // public because this struct is public
    public var body: some View {
        NavigationStack {
            Text("Swift Code Notes and Sample Code")
                .font(.system(size: 40))
                .bold()
                .multilineTextAlignment(.center)
            
            // back to app Home_Screen
            NavigationLink(destination: Home_Screen(), label: {
                Text("back to UpToYou app")
                    .padding()
                    .foregroundStyle(.white)
                    .background(Color.themeColor)
                    .cornerRadius(10)
            })
            
            // buttons
            HStack {
                
                // Popup sheet, button that shows a view on the same screen, shows Popup() View
                // clicking on the button makes showPopup true which activates .sheet
                Button {
                    popViewModel.showPopup = true
                } label: {
                    Image(systemName: "arrow.up")
                        .resizable()
                        .frame(width: 33, height: 33)
                }
                .sheet(isPresented: $popViewModel.showPopup) {
                    // screen to be shown
                    // the argument of popupPresented: $popViewModel.showPopup inside of Popup() is for a button in the Popup() view to close it
                    Popup(popupPresented: $popViewModel.showPopup)
                }
                
                // Alert/error message popup
                Button {
                    notesViewModel.showAlert = true
                } label: {
                    Image(systemName: "flag")
                        .resizable()
                        .frame(width: 33, height: 33)
                }
                .alert(isPresented: $notesViewModel.showAlert) {
                    Alert(title: Text("Error"),
                          message: Text("This is an error message popup"))
                }
                
                // to savedData() screen, contains data created from popup
                Button {
                    savedViewModel.showScreen = true
                } label: {
                    Image(systemName: "list.clipboard")
                        .resizable()
                        .frame(width: 33, height: 33)
                }
                .navigationDestination(isPresented: $savedViewModel.showScreen) {
                                savedData(userID: "4SLAGBjedZSupsRp7T1BVuoBowt1")
                    }
                
                // mock profile of a logged in user
                Button {
                    userViewModel.showScreen = true
                } label: {
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 33, height: 33)
                }
                .navigationDestination(isPresented: $userViewModel.showScreen) {
                        profile()
                    }
                
    
            }
            
            
            Spacer()
        } // end of navigation stack
    } // end of body view
} // end of YT_notes_code view

#Preview {
    swift_notes_code()
}
