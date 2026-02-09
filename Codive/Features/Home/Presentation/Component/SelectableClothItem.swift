//
//  SelectableClothItem.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

struct SelectableClothItem: View {
    let entity: CodiItemEntity
    @Binding var isSelected: Bool
    
    var body: some View {
        ZStack {
            AsyncImage(url: URL(string: entity.imageUrl)) { phase in
                if let image = phase.image {
                    image.resizable().scaledToFill()
                } else {
                    Color.gray.opacity(0.2)
                }
            }
            .frame(width: 68, height: 68)
            .clipped()
            .cornerRadius(8)
        }
        .frame(width: 72, height: 72)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        }
        .onTapGesture {
            isSelected.toggle()
        }
    }
}
