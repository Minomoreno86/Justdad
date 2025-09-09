//
//  EmergencyContactCard.swift
//  SoloPapá
//
//  Created by Jorge Vasquez rodriguez on 8/9/25.
//

import SwiftUI

struct EmergencyContactCard: View {
    let title: String
    let subtitle: String
    let phone: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button(action: {
                // Make phone call
            }) {
                HStack {
                    Image(systemName: "phone.fill")
                    Text(phone)
                }
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(color)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal, 20)
    }
}
