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
            Image(entity.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 68, height: 68)
                .clipped()
        }
        .frame(width: 72, height: 72)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? .black : .gray, lineWidth: 1)
        )
        .onTapGesture {
            isSelected.toggle()
        }
    }
}
