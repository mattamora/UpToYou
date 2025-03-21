//
//  Favorite_Item_Rating.swift
//  UpToYou
//
//  Created by Maria Lontok on 3/21/25.
//

import SwiftUI

struct StarRatingView: View {
    let rating: Double
    let maxStars = 5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxStars, id: \.self) { index in
                Image(systemName: starType(for: index))
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.yellow)
                    
            }
        }
    }

    // Determines which star icon to use
    private func starType(for index: Int) -> String {
        let fullStarThreshold = Double(index) + 1
        if rating >= fullStarThreshold {
            return "star.fill"
        } else if rating > Double(index) && rating < fullStarThreshold {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
}
