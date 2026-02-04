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
    
    // 기존: 선택된 옷 리스트
    var selectedClothes: [HomeClothEntity]
    
    // 추가: 옷 리스트가 아닌 단일 이미지 URL (Optional)
    var singleImageUrl: String? = nil
    
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
    
//    private var popupCard: some View {
//        VStack(spacing: 6) {
//            Text(TextLiteral.Home.popUpTitle).font(.codive_title1).padding(.top, 32)
//            Text(TextLiteral.Home.popUpSubtitle).font(.codive_body2_regular).padding(.horizontal, 24)
//            
//            // --- 이미지 영역 분기 처리 ---
//            if let imageUrl = singleImageUrl {
//                // 단일 이미지 케이스 (옷 리스트가 아닌 일반 이미지)
//                AsyncImage(url: URL(string: imageUrl)) { image in
//                    image.resizable()
//                        .scaledToFill()
//                } placeholder: {
//                    ProgressView()
//                }
//                .frame(width: 260, height: 260)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//                .padding(.vertical, 16)
//                
//            } else {
//                // 기존: 옷 리스트 합성 뷰
//                CodiCompositeView(clothes: selectedClothes)
//                    .frame(width: 260, height: 260)
//                    .padding(.vertical, 16)
//            }
//            // -----------------------
//            
//            HStack(spacing: 9) {
//                CustomButton(text: TextLiteral.Home.close, widthType: .half, styleType: .border) {
//                    isPresented = false
//                    onCloseTapped()
//                }
//                CustomButton(text: TextLiteral.Home.record, widthType: .half) {
//                    onRecordTapped()
//                }
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 24)
//        }
//        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
//    }
    private var popupCard: some View {
        VStack(spacing: 6) {
            Text(TextLiteral.Home.popUpTitle).font(.codive_title1).padding(.top, 32)
            Text(TextLiteral.Home.popUpSubtitle).font(.codive_body2_regular).padding(.horizontal, 24)
            
            // --- 수정된 이미지 영역 ---
            Group {
                if let imageUrl = singleImageUrl, let url = URL(string: imageUrl) {
                    // ✅ AsyncImage의 phase를 직접 확인하여 상태 추적
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .onAppear { print("⏳ [Popup] 이미지 로딩 시작: \(imageUrl)") }
                        case .success(let image):
                            image.resizable()
                                .scaledToFill()
                                .onAppear { print("✅ [Popup] 이미지 로드 성공") }
                        case .failure(let error):
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("로드 실패")
                            }
                            .onAppear { print("❌ [Popup] 이미지 로드 실패: \(error.localizedDescription)") }
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
                        .onAppear { print("ℹ️ [Popup] 옷 리스트 합성 모드로 표시 중") }
                }
            }
            // -----------------------
            
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

// MARK: - 합성 레이아웃 뷰
//struct CodiCompositeView: View {
//    let clothes: [HomeClothEntity]
//    // 204 -> 260으로 변경 (아이템 3~4개 수직 배치 시 약 250pt 필요)
//    let containerSize: CGFloat = 260
//    let itemSize: CGFloat = 100
//    
//    var body: some View {
//        ZStack {
//            // 배경 영역 (검정색 사각형이 이제 260 사이즈를 가집니다)
//            Rectangle()
//                .fill(Color.clear)
//                .frame(width: containerSize, height: containerSize)
//                .cornerRadius(12) // 모서리를 살짝 깎으면 더 부드럽습니다
//            
//            // 아이템 배치
//            ForEach(0..<clothes.count, id: \.self) { index in
//                let position = CodiLayoutCalculator.position(
//                    index: index,
//                    totalCount: clothes.count,
//                    containerSize: containerSize
//                )
//                
//                AsyncImage(url: URL(string: clothes[index].imageUrl)) { image in
//                    image.resizable()
//                        .scaledToFill()
//                } placeholder: {
//                    Color.gray.opacity(0.2)
//                }
//                .frame(width: itemSize, height: itemSize)
//                .background(Color.white)
//                .clipShape(RoundedRectangle(cornerRadius: 8))
//                .position(x: position.x, y: position.y)
//                .zIndex(Double(index))
//            }
//        }
//        // 중요: ZStack 자체에 프레임을 주어 밖으로 나가는 것을 방지합니다.
//        .frame(width: containerSize, height: containerSize)
//        .clipped()
//    }
//}

// CompletePopUp.swift

struct CodiCompositeView: View {
    let clothes: [HomeClothEntity]
    var loadedImages: [Int64: UIImage]? = nil // ✅ 추가: 미리 로드된 이미지들
    
    let containerSize: CGFloat = 260
    let itemSize: CGFloat = 100
    
    var body: some View {
        ZStack {
            // ✅ 배경을 Color.white로 변경하여 캡처 시 검은색 방지
            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.white)
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
                        // ✅ 캡처용: 미리 로드된 UIImage 사용
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        // 일반 표시용: AsyncImage 사용
                        AsyncImage(url: URL(string: cloth.imageUrl)) { image in
                            image.resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.Codive.grayscale6 // 로딩 중 배경
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
