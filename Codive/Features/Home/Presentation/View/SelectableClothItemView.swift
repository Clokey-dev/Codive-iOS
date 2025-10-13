//
//  SelectableClothItemView.swift
//  Codive
//
//  Created by 한금준 on 10/13/25.
//

import SwiftUI

struct SelectableClothItemView: View {
    let imageName: String?
    @Binding var isSelected: Bool
    let size: CGFloat = 72
    
    var body: some View {
        ZStack {
            if let imageName = imageName, !imageName.isEmpty {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size - 8, height: size - 8)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.Codive.main1)
                    .frame(width: size - 8, height: size - 8)
            }
        }
        .frame(width: size, height: size)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.black : Color.Codive.grayscale6, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        .onTapGesture {
            isSelected.toggle()
        }
    }
}

#Preview {
    PreviewContainer()
}

private struct PreviewContainer: View {
    @State private var selectedIndex: Int? = 0

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { index in
                SelectableClothItemView(
                    imageName: index == 3 ? nil : "cardigan",
                    isSelected: Binding(
                        get: { selectedIndex == index },
                        set: { newValue in
                            if newValue { selectedIndex = index }
                        }
                    )
                )
            }
        }
        .padding()
    }
}
