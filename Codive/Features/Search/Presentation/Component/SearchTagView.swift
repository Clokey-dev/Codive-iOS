//
//  SearchTagV.swift
//  Codive
//
//  Created by 한금준 on 11/18/25.
//

import SwiftUI

struct SearchTagView: View {
    // MARK: - Properties
    let text: String // 표시할 검색어
    let onDelete: () -> Void // 삭제 버튼이 눌렸을 때 실행할 클로저
    
    // MARK: - Constants (디자인 값)
    private let horizontalPadding: CGFloat = 16
    private let verticalPadding: CGFloat = 7
    private let cornerRadius: CGFloat = 99
    private let borderColor = Color.Codive.grayscale3
    private let textColor = Color.Codive.grayscale3
    private let iconSize: CGFloat = 6

    var body: some View {
        HStack(spacing: 8) {
            Text(text)
                .font(Font.codive_body2_medium)
                .foregroundStyle(textColor)
 
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundStyle(textColor)
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    SearchTagView(text: "드뮤어룩") {
        print("드뮤어룩 태그 삭제")
    }
    .padding()
}
