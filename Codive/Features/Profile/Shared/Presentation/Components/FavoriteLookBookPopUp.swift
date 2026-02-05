//
//  FavoriteLookBookPopUp.swift
//  Codive
//
//  Created by 한금준 on 2/5/26.
//

import SwiftUI

struct FavoriteLookBookPopUp: View {
    let imageUrl: String
    let clothItems: [CodiItem]
    let payloads: [Payloads]
    var onClose: () -> Void
    
    @State private var showClothSelector: Bool = true
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        GeometryReader { outerGeo in
            let popupWidth = outerGeo.size.width - 40
            
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { onClose() }
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button {
                            onClose()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.black)
                                .padding(16)
                        }
                    }
                    
                    VStack(spacing: 16) {
                        let currentItem = clothItems[safe: selectedIndex]
                        let currentPayload = payloads.first {
                            $0.clothId == currentItem?.clothId
                        }
                        
                        codiDisplayArea(
                            width: popupWidth,
                            selectedItem: currentItem,
                            payload: currentPayload
                        )
                        
                        if showClothSelector {
                            clothSelector
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.bottom, 24)
                }
                .background(Color.white)
                .cornerRadius(20)
                .padding(.horizontal, 20)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showClothSelector)
            }
        }
    }
}

private extension FavoriteLookBookPopUp {
    func codiDisplayArea(width: CGFloat, selectedItem: CodiItem?, payload: Payloads?) -> some View {
        let boardSize = width - 40
        
        return ZStack(alignment: .bottomLeading) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.gray.opacity(0.1))
                
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                    } else {
                        ProgressView()
                    }
                }
                
                // MARK: - 태그 표시 조건 수정
                if showClothSelector, let item = selectedItem, let pos = payload {
                    CustomTagView(type: .basic(title: item.brand, content: item.name))
                        .position(
                            x: boardSize * CGFloat(pos.locationX),
                            y: boardSize * CGFloat(pos.locationY)
                        )
                        .transition(.opacity.combined(with: .scale))
                        .id(item.id)
                }
            }
            .frame(width: boardSize, height: boardSize)
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showClothSelector.toggle()
                }
            } label: {
                Image("ic_tag")
                    .resizable()
                    .frame(width: 28, height: 28)
            }
            .padding([.leading, .bottom], 16)
        }
    }
    
    var clothSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(clothItems.enumerated()), id: \.element.id) { index, item in
                    clothItemCell(at: index, item: item)
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 80)
    }
    
    func clothItemCell(at index: Int, item: CodiItem) -> some View {
        AsyncImage(url: URL(string: item.imageName)) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Color.gray.opacity(0.2)
        }
        .frame(width: 68, height: 68)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(selectedIndex == index ? Color.blue : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            selectedIndex = index
        }
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    FavoriteLookBookPopUp(
        imageUrl: "샘플이미지URL",
        clothItems: [
            CodiItem(id: 1, imageName: "옷이미지1", brand: "아디다스", name: "팬츠", clothId: 501),
            CodiItem(id: 2, imageName: "옷이미지2", brand: "나이키", name: "셔츠", clothId: 502)
        ],
        payloads: [
            Payloads(clothId: 501, locationX: 0.5, locationY: 0.7, ratio: 1.0, degree: 0, order: 1),
            Payloads(clothId: 502, locationX: 0.5, locationY: 0.3, ratio: 1.0, degree: 0, order: 2)
        ]
    ) {}
}
