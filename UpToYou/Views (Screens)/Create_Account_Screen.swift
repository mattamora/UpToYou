//
//  Create_Account_Screen.swift
//  UpToYou
//
//  Created by Matthew Amora on 3/2/25.
//

import SwiftUI

struct Create_Account_Screen: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.mainColor.ignoresSafeArea()
                
                Text("Create Account")
                
            } // end of ZStack
        } // end of navigation stack
        
    } // end of body view
}

#Preview {
    Create_Account_Screen()
}
