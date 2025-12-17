//
//  BeforeCodiCard.swift
//  Codive
//
//  Created by 한금준 on 12/17/25.
//

import SwiftUI

struct BeforeCodiCard: View {
    // 외부에서 받을 데이터
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

struct BeforeCodiCard_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            BeforeCodiCard(
                imageURL: "https://via.placeholder.com/160/F08080/FFFFFF?text=Date+Look",
                date: "2025.08.08",
                isSelected: true
            )
            BeforeCodiCard(
                imageURL: "https://via.placeholder.com/160/ADD8E6/000000?text=Daily+Look",
                date: "2025.08.09",
                isSelected: false
            )
            BeforeCodiCard(
                imageURL: "https://via.placeholder.com/160/90EE90/000000?text=Basic+Look",
                date: "2025.08.10",
                isSelected: false
            )
        }
    }
}
