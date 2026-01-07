// LookBookCard.swift
//
//  LookBookCard.swift
//  Codive
//
//  Created by 한금준 on 11/24/25.
//

import SwiftUI

enum CardIconType {
    case heart
    case checkmark
    case none
}

struct LookBookCard: View {
    let imageURL: String
    let cardTitle: String
    let iconType: CardIconType
    let isSelected: Bool
    var onIconTap: (() -> Void)? // 아이콘 클릭 액션 추가
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // 이미지 렌더링 영역
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle().fill(Color(.systemGray3))
                    default:
                        Rectangle().fill(Color(.systemGray5))
                    }
                }
                .frame(width: 160, height: 160)
                .cornerRadius(16)
                .clipped()
                
                // 아이콘 표시 및 클릭 영역 확보
                if iconType != .none {
                    Button {
                        onIconTap?() // 아이콘 클릭 시 액션 실행
                    } label: {
                        iconButton
                            .padding(12)
                            .contentShape(Rectangle()) // 터치 영역 확장
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Text(cardTitle)
                .font(.system(size: 14, weight: .medium))
                .lineLimit(1)
        }
        .frame(width: 160)
    }
    
    private var iconButton: some View {
        Group {
            switch iconType {
            case .heart:
                // 커스텀 이미지 "heart_on/off" 사용
                Image(isSelected ? "heart_on" : "heart_off")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            case .checkmark:
                Image(isSelected ? "check_on" : "check_off")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            default:
                EmptyView()
            }
        }
    }
}
