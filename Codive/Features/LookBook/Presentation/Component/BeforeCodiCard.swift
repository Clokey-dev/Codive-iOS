//
//  BeforeCodiCard.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

struct BeforeCodiCard: View {
    let imageURL: String
    let date: String
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color(.systemGray3))
                    default:
                        Rectangle()
                            .fill(Color(.systemGray5))
                    }
                }
                .frame(width: 160, height: 160)
                .cornerRadius(16)
                .clipped()
                
                Image(isSelected ? "check_on" : "check_off")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.white)
                    .padding(4)
                    .padding(12)
            }
            .frame(width: 160)
            
            HStack {
                Image("calendar")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .padding(10)
                
                Text(date)
                    .font(Font.codive_body2_medium)
                    .lineLimit(1)
            }
        }
    }
}
