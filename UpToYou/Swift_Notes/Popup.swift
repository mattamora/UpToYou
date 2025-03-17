//
//  Popup.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/14/25.
//

import SwiftUI

struct Popup: View {
    
    // used for Form, adding data into firebase
    @StateObject var popViewModel = PopupViewModel()
    
    // used for the button to hide the popup
    @Binding var popupPresented: Bool
    
    var body: some View {
        Text("This is a Popup Screen")
            .font(.system(size: 30))
            .underline()
            .bold()

        
        Spacer()
        VStack { // using a vstack to modify form height
            Text("This form adds sample data into firebase")
            Form {
                // TextField for single line inputs, can't change height
                TextField("Data Title", text:$popViewModel.title)
            
                // TextEditor for multi-line larger inputs, able to modify height, does not have placeholder text
                TextEditor(text: $popViewModel.actualData)
                    .frame(height: 100)
                
                
                Button {
                    popViewModel.saveToFirebase()
                    popupPresented = false
                    
                } label : {
                    Text("Save data to firebase")
                } 
            }
        }
        .frame(height: 300)
        .padding(.top, 20)
      
        
        Spacer()
        // hides popup screen instead of manually scrolling down.
        Button {
            popupPresented = false
        } label: {
            Text("Hide Popup Screen")
                .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2)
                        )
        }
       
        
    }
}

#Preview {
    Popup(popupPresented: Binding(get: {
        return true
    }, set: { _ in
    }))
}
