//
//  LookBookFolder.swift
//  Codive
//
//  Created by 한금준 on 1/16/26.
//

import SwiftUI

enum LookBookSelectionMode {
    case none
    case check(isSelected: Bool)
}

struct LookBookFolder: View {
    let imageUrl: String
    let title: String
    let count: Int
    let mode: LookBookSelectionMode
    
    // 카드 전체 클릭 시 실행될 동작
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack(alignment: .bottomTrailing) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(white: 0.96))
                        .frame(width: 90, height: 110)
                        .overlay(
                            Image(systemName: "tshirt")
                                .font(.system(size: 30))
                                .foregroundColor(.gray.opacity(0.5))
                        )

                    checkButtonOverlay
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Text("\(count)")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(white: 0.9), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var checkButtonOverlay: some View {
        if case .check(let isSelected) = mode {
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue : Color.white)
                
                Circle()
                    .strokeBorder(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .frame(width: 22, height: 22)
            .padding(8)
        }
    }
}

struct LookBookExampleView: View {
    @State private var isSelected: Bool = false
    
    var body: some View {
        HStack(spacing: 20) {
            LookBookFolder(
                imageUrl: "",
                title: "스페인여행 (이동)",
                count: 20,
                mode: .none
            ) {
                print("상세 페이지로 이동 로직 실행")
            }
            
            LookBookFolder(
                imageUrl: "",
                title: "스페인여행 (선택)",
                count: 20,
                mode: .check(isSelected: isSelected)
            ) {
                isSelected.toggle()
                print("현재 선택 상태: \(isSelected)")
            }
        }
        .padding()
    }
}

#Preview {
    LookBookExampleView()
}
