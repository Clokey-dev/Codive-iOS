//
//  CompletePopUp.swift
//  Codive
//
//  Created by 한금준 on 12/25/25.
//

import SwiftUI

struct CompletePopUp: View {
    @Binding var isPresented: Bool
    var onRecordTapped: () -> Void
    var onCloseTapped: () -> Void
    var selectedClothes: [HomeClothEntity]
    var singleImageUrl: String?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack {
                popupCard
                    .padding(.horizontal, 32)
            }
        }
    }
    
    private var popupCard: some View {
        VStack(spacing: 6) {
            Text(TextLiteral.Home.popUpTitle).font(.codive_title1).padding(.top, 32)
            Text(TextLiteral.Home.popUpSubtitle).font(.codive_body2_regular).padding(.horizontal, 24)

            Group {
                if let imageUrl = singleImageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .onAppear {
                                    #if DEBUG
                                    print("⏳ [Popup] 이미지 로딩 시작: \(imageUrl)")
                                    #endif
                                }
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .onAppear {
                                    #if DEBUG
                                    print("✅ [Popup] 이미지 로드 성공")
                                    #endif
                                }
                        case .failure(let error):
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("로드 실패")
                            }
                            .onAppear {
                                #if DEBUG
                                print("❌ [Popup] 이미지 로드 실패: \(error.localizedDescription)")
                                #endif
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 260, height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.vertical, 16)
                } else {
                    CodiCompositeView(clothes: selectedClothes)
                        .frame(width: 260, height: 260)
                        .padding(.vertical, 16)
                        .onAppear {
                            #if DEBUG
                            print("ℹ️ [Popup] 옷 리스트 합성 모드로 표시 중")
                            #endif
                        }
                }
            }
            
            HStack(spacing: 9) {
                CustomButton(text: TextLiteral.Home.close, widthType: .half, styleType: .border) {
                    isPresented = false
                    onCloseTapped()
                }
                CustomButton(text: TextLiteral.Home.record, widthType: .half) {
                    onRecordTapped()
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
    }
}

struct CodiCompositeView: View {
    let clothes: [HomeClothEntity]
    var loadedImages: [Int64: UIImage]?
    
    let containerSize: CGFloat = 260
    let itemSize: CGFloat = 100
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.Codive.grayscale7)
                .frame(width: containerSize, height: containerSize)
            
            ForEach(0..<clothes.count, id: \.self) { index in
                let cloth = clothes[index]
                let position = CodiLayoutCalculator.position(
                    index: index,
                    totalCount: clothes.count,
                    containerSize: containerSize
                )
                
                Group {
                    if let uiImage = loadedImages?[cloth.clothId] {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        AsyncImage(url: URL(string: cloth.imageUrl)) { image in
                            image.resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.Codive.grayscale6
                        }
                    }
                }
                .frame(width: itemSize, height: itemSize)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .position(x: position.x, y: position.y)
                .zIndex(Double(index))
            }
        }
        .frame(width: containerSize, height: containerSize)
        .clipped()
    }
}
